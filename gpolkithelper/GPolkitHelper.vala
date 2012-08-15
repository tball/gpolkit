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
