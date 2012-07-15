using Gee;
using Polkit;

namespace GPolkit.Common {
	public class GActionDescriptor : Object {
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
		}

		public string to_string() {
			return "Policy { vendor: %s, vendor_url: %s, identity: %s, icon_name: %s, description %s, message %s }\n".printf(vendor, vendor_url, identity, icon_name, description, message);
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
	}


}
