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
using GPolkit.Views;
using GPolkit.Utilities;

namespace GPolkit.Models {
	public class ExplicitOverviewModel : BaseModel {
		private BaseModel parent_model;
		
		public Gee.List<GActionDescriptor> currently_selected_actions { get; set; default = null; }
		public Gee.List<GActionDescriptor> explicit_actions { get; set; default = null; }
		public ExplicitActionTreeStore explicit_action_list_tree_store { get; set; default = null; }
		public bool can_add_or_edit_explicit_action { get; set; default = true; }
		public Gee.List<AccountProperties> account_properties { get; set; default = null; }
		public GActionDescriptor selected_explicit_action { get; set; default = null; }
		
		public ExplicitOverviewModel(BaseModel parent) {
			parent_model = parent;
			init();
		}
		
		protected void init_account_list() {
			account_properties = AccountFunctions.get_all_accounts();
		}
		
		protected void init() {
			// Create child models
			explicit_action_list_tree_store = new ExplicitActionTreeStore();
			
			// Create internal bindings
			this.notify["currently-selected-actions"].connect((object, sender) => {implicit_or_explicit_actions_changed();});
			this.notify["explicit-actions"].connect((object, sender) => {implicit_or_explicit_actions_changed();});
			
			// Fetch user list
			init_account_list();
		}
		
		public void explicit_action_selection_changed(TreeSelection sender) {
			// Now based on the selected explicit action, select all the actions in the action list view,
			// which follows this explicit action.
			TreeModel tree_model;
			var selected_action_tree_paths = sender.get_selected_rows(out tree_model);
			
			foreach (var selected_action_tree_path in selected_action_tree_paths) {
				TreeIter tree_iter;
				Value action_descriptor_value;
				if (!tree_model.get_iter(out tree_iter, selected_action_tree_path)) {
					continue;
				}
				
				tree_model.get_value(tree_iter, ExplicitActionTreeStore.ColumnTypes.OBJECT, out action_descriptor_value);
				selected_explicit_action = action_descriptor_value.get_object() as GActionDescriptor;
			}
		}
		
		
		private void implicit_or_explicit_actions_changed()
		{
			explicit_action_list_tree_store.update_policies(currently_selected_actions, explicit_actions);
		}
		
		private void explicit_action_saved(GActionDescriptor saved_action_descriptor)
		{
			if (!explicit_actions.contains(saved_action_descriptor)) {
				explicit_actions.add(saved_action_descriptor);
			}
			
			implicit_or_explicit_actions_changed();
		}
		
		public void add_or_edit_explicit_action(GActionDescriptor? edited_action) {
			stdout.printf("Edited action %s\n", edited_action == null ? "null" : edited_action.identity);
			can_add_or_edit_explicit_action = false;
			
			var explicit_editor_window_model = new ExplicitEditorWindowModel();
			var explicit_editor_window_view = new ExplicitEditorWindowView();
			
			explicit_editor_window_model.edited_explicit_action_saved.connect(explicit_action_saved);
			
			explicit_editor_window_view.destroy.connect((sender) => { can_add_or_edit_explicit_action = true; });
			explicit_editor_window_view.connect_model(explicit_editor_window_model);
			explicit_editor_window_view.show_all();
			explicit_editor_window_model.currently_selected_actions = currently_selected_actions;
			explicit_editor_window_model.unsaved_explicit_action = edited_action;
			explicit_editor_window_model.account_properties = account_properties;
		}
	}
}
