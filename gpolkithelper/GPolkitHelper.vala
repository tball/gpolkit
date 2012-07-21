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

namespace GPolkit.Helper {
	[DBus (name = "org.gnome.gpolkit.helper")]
	public class GPolkitHelper : Object {
		public HashTable<string,Variant>[] get_implicit_policies () {
			// Grant permission

			// Fetch policy file paths
			// /var policy_file_paths = get_policy_file_paths();

			// Parse the files
			// /var policies = get_policies_from_xml_files(policy_file_paths);

			Authority authority;
			try {
				authority = Authority.get_sync();
			}
			catch(GLib.Error err) {
				throw new GPolkitHelperError.SOME_ERROR("Could not get the Authority object from polkit.");
			}

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
		// var gpolkit_helper = new GPolkitHelper();
		// var hashes = gpolkit_helper.get_implicit_policies () ;

		Bus.own_name (BusType.SESSION, "org.gnome.gpolkit.helper", BusNameOwnerFlags.NONE,
					  on_bus_aquired,
					  () => {},
					  () => stderr.printf ("Could not aquire name\n"));

		new MainLoop ().run ();
	}
}
