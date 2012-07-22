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
		public HashTable<string,Variant>[] get_implicit_policies (BusName bus_name) throws GLib.Error {
			Authority authority;
			try {
				authority = Authority.get_sync();
			}
			catch(GLib.Error err) {
				throw new GPolkitHelperError.SOME_ERROR("Could not get the Authority object from polkit.");
			}
			
			// Grant permission
			Subject subject;
			try {
				subject = Polkit.SystemBusName.new(bus_name);
			}
			catch(GLib.Error err) {
				throw new GPolkitHelperError.SOME_ERROR("Error received while getting the subject: ." + err.message);
			}

			AuthorizationResult result;
			try {
				result = authority.check_authorization_sync(subject, "org.gnome.gpolkit.readauthorizations", null, Polkit.CheckAuthorizationFlags.ALLOW_USER_INTERACTION, null);
			}
			catch(GLib.Error err) {
				throw new GPolkitHelperError.SOME_ERROR("Error received while getting the result: ." + err.message);
			}
			
			if (!result.get_is_authorized ()) {
				throw new GPolkitHelperError.SOME_ERROR("Unautorized.");
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
		Bus.own_name (BusType.SYSTEM, "org.gnome.gpolkit.helper", BusNameOwnerFlags.NONE,
					  on_bus_aquired,
					  () => {},
					  () => stderr.printf ("Could not aquire name\n"));

		new MainLoop ().run ();
	}
}
