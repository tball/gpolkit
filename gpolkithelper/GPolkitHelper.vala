/**
 * GPolkit is a gtk based polkit authorization manager.
 * Copyright (C) 2012  Thomas Balling Sørensen
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 **/

using Gee;
using Xml;
using Polkit;
using GPolkit.Common;

namespace GPolkit.Helper 
{
	public static string last_of_string_array(string[] str_array)
	{
		return str_array[str_array.length - 1];
	}
	
	[DBus (name = "org.gnome.gpolkit.helper")]
	public class GPolkitHelper : Object
	{
		private bool grant_permission(string bus_name, string action_id, out string error) throws GLib.Error  {
			AuthorizationResult result;
			try {
				var authority = Authority.get_sync();
				var subject = SystemBusName.new(bus_name);
				result = authority.check_authorization_sync(subject, action_id, null, CheckAuthorizationFlags.ALLOW_USER_INTERACTION, null);
			}
			catch(GLib.Error err) {
				error = err.message;
				return false;
			}

			if (!result.get_is_authorized ()) {
				error = "Unauthorized";
				return false;
			}
			
			error = "";
			return true;
		}
	
		public HashTable<string,Variant>[] get_implicit_policies (BusName bus_name) throws GLib.Error {
			string error_str;
			if (!grant_permission(bus_name, "org.gnome.gpolkit.readauthorizations", out error_str)) {
				throw new GPolkitHelperError.SOME_ERROR("Cannot read policies due to the following error: " + error_str);
			}
			
			var authority = Authority.get_sync();
			GLib.List<Polkit.ActionDescription> action_descriptors;
			try {
				action_descriptors = authority.enumerate_actions_sync(null);
			}
			catch(GLib.Error err) {
				throw new GPolkitHelperError.SOME_ERROR("Could not enumerate implicit actions.");
			}

			var g_action_descriptors_hash_table = new HashTable<string,Variant>[action_descriptors.length()];
			var i = 0;
			foreach (Polkit.ActionDescription action_desc in action_descriptors)
			{
				var g_action_description = new GActionDescriptor(action_desc);
				g_action_descriptors_hash_table[i] = GActionDescriptor.serialize(g_action_description);
				i++;
			}
			return g_action_descriptors_hash_table;
		}
		
		public HashTable<string,Variant>[] get_explicit_policies (BusName bus_name) throws GLib.Error {
			string error_str;
			if (!grant_permission(bus_name, "org.gnome.gpolkit.readauthorizations", out error_str)) {
				throw new GPolkitHelperError.SOME_ERROR("Cannot read policies due to the following error: " + error_str);
			}
			
			var explicit_policies = read_explicit_policies();
			if (explicit_policies == null) {
				return new HashTable<string,Variant>[0];
			}
			
			return GActionDescriptor.serialize_array(explicit_policies);
		}
		
		public void set_implicit_policies (HashTable<string,Variant>[] implicit_policies, BusName bus_name) throws GLib.Error {
			string error_str;
			if (!grant_permission(bus_name, "org.gnome.gpolkit.changeimplicitauthorizations", out error_str)) {
				throw new GPolkitHelperError.SOME_ERROR("Cannot read policies due to the following error: " + error_str);
			}
			
			// De-serialize hashtable
			Gee.List<GActionDescriptor> actions = GActionDescriptor.de_serialize_array(implicit_policies);
			
			// Save them if changed
			foreach (var action in actions) {
				if (action.changed == "true") {
					save_implicit_action(action);
				}
			}
		}
		
		public void set_explicit_policies (HashTable<string,Variant>[] explicit_policies, BusName bus_name) throws GLib.Error {
			
		}
		
		private Gee.List<GActionDescriptor> read_explicit_policies() {
			var action_descriptors = new ArrayList<GActionDescriptor>();
			
			// Search for possible policy files
			Gee.List<string> policy_paths = new ArrayList<string>();
			var explicit_var_policy_paths = get_explicit_policy_file_paths(Ressources.EXPLICIT_VAR_DIR);
			var explicit_etc_policy_paths = get_explicit_policy_file_paths(Ressources.EXPLICIT_ETC_DIR);
			
			if (explicit_var_policy_paths != null) {
				policy_paths.add_all(explicit_var_policy_paths);
			}
			
			if (explicit_etc_policy_paths != null) {
				policy_paths.add_all(explicit_etc_policy_paths);
			}
			
			// Parse the files
			foreach(var path in policy_paths) {
				var actions = get_actions_from_path(path);
				if (actions != null) {
					action_descriptors.add_all(actions);
				}
			}
			
			return action_descriptors;
		}
		
		private ArrayList<GActionDescriptor>? get_actions_from_path(string path) {
			var action_descriptors = new ArrayList<GActionDescriptor>();
			var file = File.new_for_path (path);

			if (!file.query_exists ()) {
				stdout.printf ("File '%s' doesn't exist.\n", file.get_path());
				return null;
			}
			
			try {
				// Open file for reading and wrap returned FileInputStream into a
				// DataInputStream, so we can read line by line
				var dis = new DataInputStream (file.read ());
				string line;
				// Read lines until end of file (null) is reached
				while ((line = dis.read_line (null)) != null) {
					if (line.get(0) =='[') {
						var action = new GActionDescriptor(null);
						action.file_path = path;
						var title_parts = line.split("[");
						action.title = title_parts[title_parts.length - 1].split("]")[0];

						while ((line = dis.read_line (null)) != null) {
							if (line.contains("Identity=")) {
								var identity_parts = line.split("Identity=");
								action.user_names = last_of_string_array(identity_parts);
							} else if (line.contains("Action=")) {
								action.identity = last_of_string_array(line.split("Action="));
							} else if (line.contains("ResultAny=")) {
								action.allow_any = last_of_string_array(line.split("ResultAny="));
							} else if (line.contains("ResultInactive=")) {
								action.allow_inactive = last_of_string_array(line.split("ResultInactive="));
							} else if (line.contains("ResultActive=")) {
								action.allow_active = last_of_string_array(line.split("ResultActive="));
							} else if (line[0] == '[') {
								// Ouch!!
								stdout.printf("Error while reading file: %s\n", path);
								return null;
							}

							// Did we parse it all?
							if (action.identity != "" && action.user_names != "" && action.allow_active != "" &&
								action.allow_any != "" && action.allow_inactive != "" && action.file_path != "") {

								action_descriptors.add(action);
								break;
							}
						}
					}
				}
			} catch (GLib.Error e) {
				stdout.printf ("Catched error while reading file: %s", e.message);
				return null;
			}
			
			return action_descriptors;
		}
		
		private Gee.List<string>? get_explicit_policy_file_paths(string search_path)
		{
			var policy_paths = new ArrayList<string>();
			var search_file = File.new_for_path(search_path);
			try {
				var file_type = search_file.query_file_type(FileQueryInfoFlags.NONE);
				if (file_type == FileType.DIRECTORY) {
					var file_enumerator = search_file.enumerate_children(FileAttribute.STANDARD_NAME, FileQueryInfoFlags.NONE);
					FileInfo file_info;
					while ((file_info = file_enumerator.next_file ()) != null) {
						var child_path = search_path + "/" + file_info.get_name();
						// stdout.printf("Child path: %s\n", child_path);
						var new_policy_paths = get_explicit_policy_file_paths(child_path);
						
						if (new_policy_paths != null) {
							policy_paths.add_all(new_policy_paths);
						}
					}
				}
				else if (file_type == FileType.REGULAR) {
					var file_name = search_file.query_info(FileAttribute.STANDARD_NAME, FileQueryInfoFlags.NONE).get_name();
					string[] splitted_file_name = file_name.split(".");
					if (splitted_file_name[splitted_file_name.length - 1] == "pkla") {
						// stdout.printf("Adding %s file to the policy paths\n", search_path);
						policy_paths.add(search_path);
					}
				}
			}
			catch (GLib.Error err) {
				stdout.printf("Catched an error while parsing directory %s. Error: %s\n", search_path, err.message);
				return null;
			}
			return policy_paths;
		}
		
		private bool find_action_path_from_id(string action_id, out string action_path) {
			var root_path = Ressources.ACTION_DIR;
			var action_search_prefixes = action_id.split(".");
			
			bool found_path = false;
			while (true) {
				action_path = root_path + "/" + string.joinv(".", action_search_prefixes) + ".policy";
				// stdout.printf("Searching for implicit action at " + action_path + "\n");
				
				var action_file = File.new_for_path(action_path );
				if (action_file.query_exists()) {
					// stdout.printf("Found implicit action at " + action_path + "\n");
					found_path = true;
					break;
				}
				
				// Should we give up our search?
				if (action_search_prefixes.length <= 2) {
					return false;
				}
				
				// Remove last search prefix
				action_search_prefixes = action_search_prefixes[0: action_search_prefixes.length - 1];
			}
			
			return found_path;
		}
		
		private void save_implicit_action(GActionDescriptor action) {
			string action_path;
			if (!find_action_path_from_id(action.identity, out action_path)) {
				stdout.printf("Didn't find path for action %s\n", action.identity);
				return;
			}
			
			// TODO: Write the xml entry
			Xml.Doc* doc = Parser.parse_file (action_path);
			if (doc == null) {
				stdout.printf("Doc == null for action %s\n", action.identity);
				return;
        	}
			
			// Get the root node. notice the dereferencing operator -> instead of .
		    Xml.Node* root = doc->get_root_element ();
		    if (root == null) {
		        // Free the document manually before returning
		        stdout.printf("Null root element, %s\n", action.identity);
		        delete doc;
		        return;
		    }
		    
		    // Search for the first action node
		    var action_node = first_child_node(root, "action");
		    if (action_node == null) {
		    	// Didn't find any action nodes
		    	stdout.printf("Didn't find any action nodes for path %s action %s\n", action_path, action.identity);
		    	return;
		    }
		    
		    // Search for the action node with our action_id
		    Xml.Attr* prop = action_node->properties;
		    string attr_content = "";
		    while (action_node != null) {
		    	prop = action_node->properties;
		    	attr_content = prop->children->content;
		    	
		    	if (prop->name == "id" && attr_content == action.identity) {
		    		// Correct node found
		    		break;
		    	}
		    	
		    	action_node = next_sibling_node(action_node, "action");
		    }
		    
		    if (action_node == null) {
		    	stdout.printf("Didn't find the right action node for id %s path %s\n", action.identity, action_path);
		    	return;
		    }
		    
		    // Find the defaults node under the action node
		    var defaults_node = first_child_node(action_node, "defaults");
		    if (defaults_node == null) {
		    	// Didn't find any defaults nodes
		    	stdout.printf("Didn't find any defaults nodes for path %s action %s\n", action_path, action.identity);
		    	return;
		    }
		    

		    // Set or overwrite the 3 nodes
		    add_child_node_with_content(defaults_node, "allow_any", action.allow_any);
		    add_child_node_with_content(defaults_node, "allow_inactive", action.allow_inactive);
		    add_child_node_with_content(defaults_node, "allow_active", action.allow_active);
		    
		    // Now save the doc
		    doc->save_file(action_path);
		    
			// Manually cleanup the xml doc
			delete doc;
		}
		
		private void add_child_node_with_content(Xml.Node *parent, string child_name, string content) {
			Xml.Ns* ns = new Xml.Ns (null, "", "");
        	ns->type = Xml.ElementType.ELEMENT_NODE;
		
			var child_node = first_child_node(parent, child_name);
		    if (child_node == null) {
		    	// Create new child node
		    	parent->new_text_child (ns, child_name, content);
		    } else {
		    	child_node->set_content(content);
		    }
		}
		
		private Xml.Node* next_sibling_node(Xml.Node *node, string searched_node_name) {
			Xml.Node* sibling_node = node->next;
			while (sibling_node != null) {
				if (sibling_node->type != ElementType.ELEMENT_NODE) {
					sibling_node = sibling_node->next;
		            continue;
		        }
				
				if (sibling_node->name == searched_node_name) {
					return sibling_node;
				}
				sibling_node = sibling_node->next;
			}
			
			return null;
		}
		
		private Xml.Node* first_child_node(Xml.Node *parent_node, string searched_node_name) {
		    // Loop over the passed node's children
		    for (Xml.Node* iter = parent_node->children; iter != null; iter = iter->next) {
		        // Spaces between tags are also nodes, discard them
		        if (iter->type != ElementType.ELEMENT_NODE) {
		            continue;
		        }

		        if (iter->name == searched_node_name) {
		        	return iter;
		        }

		        // Followed by its children nodes
		        var child_node = first_child_node (iter, searched_node_name);
		        if (child_node != null) {
		        	return child_node;
		        }
		    }
		    
		    // We didn't find anything in this node
		    return null;
		}
	}


	[DBus (name = "org.gnome.gpolkit.GPolkitHelperError")]
	public errordomain GPolkitHelperError
	{
		SOME_ERROR
	}

	void on_bus_aquired (DBusConnection conn) {
		try {
			conn.register_object ("/org/gnome/gpolkit/helper", new GPolkitHelper());
		}
		catch (IOError e) {
			stderr.printf ("Could not register service\n");
		}
	}

	void main() {
		Bus.own_name (BusType.SYSTEM, "org.gnome.gpolkit.helper", BusNameOwnerFlags.NONE,
					  on_bus_aquired,
					  () => {},
					  () => stderr.printf ("Could not aquire name\n"));

		new MainLoop ().run ();
	}
}
