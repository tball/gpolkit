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
			var actions = GActionDescriptor.de_serialize_array(implicit_policies);
			
			// Save them
			foreach (var action in actions) {
				save_implicit_action(action);
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
				return;
			}
			
			// TODO: Write the xml entry
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
