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
 
using Gtk;
using Gee;
using GPolkit.Common;
 
 namespace GPolkit.Models {
	 public class ActionListTreeStoreProxy : TreeStore {
		 public string filter_string {get; set; default="";}
		
		public enum ColumnTypes
		{
			ICON = 0,
			GROUP_ID,
			DESCRIPTION,
			ACTION_REF,
		}
		
		public TreeModelFilter TreeStoreFilter { get; private set; }
	
		public ActionListTreeStoreProxy() {
			TreeStoreFilter = new TreeModelFilter(this, null);
			TreeStoreFilter.set_visible_func(visibility_func);
			set_column_types(new Type[] {typeof(string), typeof (string), typeof (string), typeof(GActionDescriptor)});
			
			// Create bindings
			this.notify["filter-string"].connect((sender) => {TreeStoreFilter.refilter();});
		}

		public TreeModel get_filtered_tree_model() {
			return TreeStoreFilter;
		}

		private bool visibility_func(TreeModel model, TreeIter iter)
		{
			if (filter_string == "")
			{
				// Search aborted
				return true;	
			}
			
			var lower_case_filter_string = filter_string.down();
			
			//
			var parent_contains_string = parent_contains_string(lower_case_filter_string, new int [] { ColumnTypes.GROUP_ID, ColumnTypes.DESCRIPTION }, iter);
			if (parent_contains_string) {
				return true;
			}
			
			// Search if current TreeIter or any of its childs contains the search string
			return current_or_children_contains_string(lower_case_filter_string, new int [] { ColumnTypes.GROUP_ID, ColumnTypes.DESCRIPTION }, iter);
		}
		
		private bool parent_contains_string(string search_string, int [] columns, TreeIter child)
		{
			TreeIter parent;
			if (!iter_parent(out parent, child)) {
				return false;
			}

			foreach (var column in columns) {
				Value parent_value;
				get_value(parent, column, out parent_value);
				var parent_string = parent_value.get_string();
			
				if (parent_string != null) {
					parent_string = parent_string.down();
					if (parent_string.contains(search_string)) {
						return true;
					}
				}
			}
			
			var parent_containts_string = parent_contains_string(search_string, columns, parent);
			if (parent_containts_string) {
				return true;
			}
			
			return false;
		}
		
		private bool current_or_children_contains_string(string search_string, int [] columns, TreeIter parent)
		{
			// See if parent contains string
			foreach (var column in columns) {
				Value parent_value;
				get_value(parent, column, out parent_value);
				var parent_string = parent_value.get_string();
			
				if (parent_string != null) {
					parent_string = parent_string.down();
					if (parent_string.contains(search_string)) {
						return true;
					}
				}
			}
				
			// Search children
			TreeIter child_iter;
			if (iter_n_children(parent) > 0) {
				iter_children(out child_iter, parent);
				do {
					var string_found_in_child = current_or_children_contains_string(search_string, columns, child_iter);
					if (string_found_in_child)
						return true;
				} while (iter_next(ref child_iter));
			}
			
			// We did not find the string
			return false;
		}
		

		public void policies_changed(Object prop, ParamSpec spec) {
			Value prop_value = Value(spec.value_type);
			prop.get_property(spec.name, ref prop_value);

			ArrayList<GActionDescriptor> policies = (ArrayList<GActionDescriptor>)prop_value.get_object();

			update_policies(policies);
		}

		public void update_policies(Gee.List<GActionDescriptor> actions) {
			clear();
			
			// Parse policies			
			foreach (GActionDescriptor action in actions) {
				var action_ids = action.identity.split(".");
				
				if (action_ids.length > 2) {
					// We start at array index 1, in order to skip 'org'
				    // var first_action_id = action_ids[1];
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
				set(parent, ColumnTypes.ICON, action.icon_name != "" ? action.icon_name : "folder-symbolic", -1);
				
				TreeIter child_iter;
				
				append(out child_iter, parent);
				set(child_iter, ColumnTypes.ICON, "channel-secure-symbolic", ColumnTypes.GROUP_ID, action.description, ColumnTypes.ACTION_REF, action, -1);
				
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
			
			set(child_iter, ColumnTypes.ICON, "folder-symbolic", ColumnTypes.GROUP_ID, action_ids[level], -1);
			insert_or_update(action_ids, action, child_iter, level + 1);
		}
	 }
 } 
