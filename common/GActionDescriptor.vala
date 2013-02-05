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
using Polkit;

namespace GPolkit.Common {
	public class GActionDescriptor : Object {
		public string title { get; set; default = ""; }
		public string vendor { get; set; default = ""; }
		public string vendor_url { get; set; default = ""; }
		public string identity { get; set; default = ""; }
		public string icon_name { get; set; default = ""; }
		public string description { get; set; default = ""; }
		public string message { get; set; default = ""; }
		public string file_path { get; set; default = ""; }
		public string allow_any { get; set; default = ""; }
		public string allow_inactive { get; set; default = ""; }
		public string allow_active { get; set; default = ""; }
		public string changed { get; set; default = "false"; }
		public string action_type { get; set; default = ""; }
		public string user_names { get; set; default = ""; }

		public void copy_to(GActionDescriptor dest_action) {
			dest_action.title = title;
			dest_action.vendor = vendor;
			dest_action.vendor_url = vendor_url;
			dest_action.identity = identity;
			dest_action.icon_name = icon_name;
			dest_action.description = description;
			dest_action.message = message;
			dest_action.file_path = file_path;
			dest_action.allow_any = allow_any;
			dest_action.allow_inactive = allow_inactive;
			dest_action.allow_active = allow_active;
			dest_action.changed = changed;
			dest_action.action_type = action_type;
			dest_action.user_names = user_names;
		}

		public void copy_from(GActionDescriptor src_action) {
			title = src_action.title;
			vendor = src_action.vendor;
			vendor_url = src_action.vendor_url;
			identity = src_action.identity;
			icon_name = src_action.icon_name;
			description = src_action.description;
			message = src_action.message;
			file_path = src_action.file_path;
			allow_any = src_action.allow_any;
			allow_inactive = src_action.allow_inactive;
			allow_active = src_action.allow_active;
			changed = src_action.changed;
			action_type = src_action.action_type;
			user_names = src_action.user_names;
		}
		
		public GActionDescriptor(ActionDescription ? action_description) {
			if (action_description != null) {
				vendor = action_description.get_vendor_name();
				vendor_url = action_description.get_vendor_url();
				identity = action_description.get_action_id();
				icon_name = action_description.get_icon_name();
				description = action_description.get_description();
				message = action_description.get_message();
				allow_any = ImplicitAuthorization.to_string(action_description.get_implicit_any());
				allow_inactive = ImplicitAuthorization.to_string(action_description.get_implicit_inactive());
				allow_active = ImplicitAuthorization.to_string(action_description.get_implicit_active());
			}
			else {
				vendor = "";
				vendor_url = "";
				identity = "";
				icon_name = "";
				description = "";
				message = "";
				allow_any = ImplicitAuthorization.to_string(ImplicitAuthorization.NOT_AUTHORIZED);
				allow_inactive = ImplicitAuthorization.to_string(ImplicitAuthorization.NOT_AUTHORIZED);
				allow_active = ImplicitAuthorization.to_string(ImplicitAuthorization.NOT_AUTHORIZED);
			}
		}

		public string to_string() {
			return "Policy {\n identity: %s\n vendor: %s\n vendor_url: %s\n icon_name: %s\n description: %s\n message: %s\n title: %s\n user_names: %s\n file_path: %s\n}\n".printf(identity, vendor, vendor_url, icon_name, description, message, title, user_names, file_path);
		}
		
		public string[] ?get_identities() {
			if ( identity == null ) {
				return null;
			}
			
			return identity.split(";");
		}

		public static int get_authorization_index_from_string(string authorization_string) {
			ImplicitAuthorization implicit_authorization;
			ImplicitAuthorization.from_string(authorization_string, out implicit_authorization);
			return implicit_authorization;
		}
		
		public static string get_authorization_string_from_index(int authorization_index) {
			var implicit_authorization = (ImplicitAuthorization)authorization_index;
			return ImplicitAuthorization.to_string(implicit_authorization);
		}

		public static HashTable<string, Variant> serialize(GActionDescriptor obj) {
			var hash = new HashTable<string, Variant>(null, null);
			var objClass = (ObjectClass)(typeof(GActionDescriptor)).class_ref ();
			var properties = objClass.list_properties ();

			// Serialize common string
			foreach (var prop in properties) {
				if (prop.value_type == typeof(string)) {
					Value prop_value = Value(typeof(string));
					obj.get_property(prop.name, ref prop_value);
					hash.set(prop.name, new Variant.string(prop_value.get_string()));
				}
			}
			return hash;
		}

		public static GActionDescriptor de_serialize(HashTable<string, Variant> hash) {
			var policy = new GActionDescriptor(null);
			var policy_class = (ObjectClass) typeof (GActionDescriptor).class_ref ();
			var properties = policy_class.list_properties ();
			foreach (var prop in properties) {
				// Deserialize common strings
				if (hash.contains(prop.name) && prop.value_type == typeof(string))
					policy.set_property(prop.name, hash.get(prop.name).get_string());
			}
			return policy;
		}
		
		public static ArrayList<GActionDescriptor> de_serialize_array(HashTable<string, Variant>[] hashes) {
			var action_descriptors = new ArrayList<GActionDescriptor>();
			foreach(var hash in hashes) {
				action_descriptors.add(de_serialize(hash));
			}
			return action_descriptors;
		}
		
		public static HashTable<string, Variant>[] serialize_array(Gee.List<GActionDescriptor> actions) {
			var action_hashes = new HashTable<string, Variant>[actions.size];
			for(var i = 0; i < actions.size; i++) {
				action_hashes[i] = serialize(actions[i]);
			}
			return action_hashes;
		}
	}


}
