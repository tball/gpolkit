using Gtk;
using Gee;
using GPolkit.Common;

namespace GPolkit.Gui
{
	public class TreeStoreProxy : TreeStore {
		public enum ColumnTypes
		{
			ICON = 0,
			GROUP_ID,
			DESCRIPTION,
			ACTION_REF
		}
	
		public TreeStoreProxy() {
			set_column_types(new Type[] {typeof(string), typeof (string), typeof (string), typeof(GActionDescriptor)});
			
		}

		public void policies_changed(Object prop, ParamSpec spec) {
			Value prop_value = Value(spec.value_type);
			prop.get_property(spec.name, ref prop_value);

			ArrayList<GActionDescriptor> policies = (ArrayList<GActionDescriptor>)prop_value.get_object();

			update_policies(policies);
		}

		public void update_policies(ArrayList<GActionDescriptor> actions) {
			clear();
			
			// Parse policies			
			foreach (GActionDescriptor action in actions) {
				var action_ids = action.identity.split(".");
				
				if (action_ids.length > 2) {
					// We start at array index 1, in order to skip 'org'
				    var first_action_id = action_ids[1];
				    insert_or_update(action_ids, action, null, 1);
				} else if (action_ids.length > 1) {
				    // although pretty weird and probably
				    // bad behavior, here we check if the action
				    // id is bigger than "org"
				    //insert_or_update(action_ids, action, root, 0);
				}
				
				//TreeIter root;
				//append(out root, null);
				//set(root, 0, policy.Identity, -1);
			}
		}
		
		private void insert_or_update(string[] action_ids, GActionDescriptor action, TreeIter? parent, int level)
		{
			// Lets see if we have come to the 'end' of the path
			if (action_ids.length - 1 <= level) {
				// now bind the action to this iter
				//stdout.printf("Reached outter level at %d with group %s\n", level, action_ids[level]);
				
				// Set icon to the parent of this entry
				set(parent, ColumnTypes.ICON, action.icon_name != "" ? action.icon_name : "emblem-system", -1);
				
				TreeIter child_iter;
				
				append(out child_iter, parent);
				set(child_iter, ColumnTypes.ICON, "stock_file-properties", ColumnTypes.GROUP_ID, action.description, ColumnTypes.ACTION_REF, action, -1);
				
				return;
			}
		
			TreeIter child_iter;
			var group_found = false;
			if (iter_n_children(parent) > 0) {
				//stdout.printf("parent does have children\n");
				// Lets see if the group has already been added
				iter_children(out child_iter, parent);
				do {
					Value child_value;
					get_value(child_iter, ColumnTypes.GROUP_ID, out child_value);
					
					var child_string = child_value.get_string();
					if (child_string == action_ids[level]) {
						//stdout.printf("Found group match: %s\n", child_string);
						group_found = true;
						break;
					}
				} while (iter_next(ref child_iter));
				
				// If we didn't find a group, append a new group
				if (!group_found) {
					// Add new child
					//stdout.printf("No group found\n");
					append(out child_iter, parent);
				}
			} else {
				//stdout.printf("parent does not have children\n");
				append(out child_iter, parent);
			}
			
			set(child_iter, ColumnTypes.ICON, "folder", ColumnTypes.GROUP_ID, action_ids[level], -1);
			insert_or_update(action_ids, action, child_iter, level + 1);
		}
	}
}
