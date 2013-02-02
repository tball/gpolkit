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
using GPolkit.Utilities;

namespace GPolkit.Models {
	public class ExplicitEditorWindowModel : BaseModel {
		public UserListTreeStore selected_user_list_tree_store;
		public UserListTreeStore not_selected_user_list_tree_store;
		public GActionDescriptor edited_explicit_action { get; set; default = null; }
		public GActionDescriptor unsaved_explicit_action { get; set; default = null; }
		public Gee.List<AccountProperties> account_properties { get; set; default = null; }
		public Gee.List<AccountProperties> selected_account_properties { get; set; default = null; }
		public Gee.List<AccountProperties> not_selected_account_properties { get; set; default = null; }
		public string title { get; set; default = null; }
		public string identity { get; set; default = null; }
		public string unsaved_title { get; set; default = null; }
		public ImplicitEditorModel implicit_editor_model;
		
		public signal void edited_explicit_action_changed();
		
		public ExplicitEditorWindowModel() {
			init();
		}
		
		protected void init() {
			// Init model children
			implicit_editor_model = new ImplicitEditorModel(this);
			selected_user_list_tree_store = new UserListTreeStore();
			not_selected_user_list_tree_store = new UserListTreeStore();
			
			// Init internal bindings
			this.notify["unsaved-explicit-action"].connect(() => { action_or_users_changed(); });
			this.notify["account-properties"].connect(() => { action_or_users_changed(); });
			
			// Bind child models
			this.bind_property("edited-explicit-action", implicit_editor_model, "edited-implicit-action");
			this.bind_property("not-selected-account-properties", not_selected_user_list_tree_store, "account-properties");
			this.bind_property("selected-account-properties", selected_user_list_tree_store, "account-properties");
		}
		
		private void action_or_users_changed() {
			if (unsaved_explicit_action == null || account_properties == null) {
				title = "";
				return;
			}
			
			var implicit_edited_action = new GActionDescriptor(null);
			implicit_edited_action.copy_from(unsaved_explicit_action);
			edited_explicit_action = implicit_edited_action;
			
			title = unsaved_explicit_action.title;
			
			// Search for selected and non selected users
			var temp_selected_account_properties = new ArrayList<AccountProperties>();
			var temp_not_selected_account_properties = new ArrayList<AccountProperties>();
			foreach (var account_property in account_properties) {
				if (unsaved_explicit_action.user_names.contains(account_property.user_name)) {
					temp_selected_account_properties.add(account_property);
				}
				else {
					temp_not_selected_account_properties.add(account_property);
				}
			}
			selected_account_properties = temp_selected_account_properties;
			not_selected_account_properties = temp_not_selected_account_properties;
		}
		
		public void save_explicit_action() {
			unsaved_explicit_action.copy_from(edited_explicit_action);
			unsaved_explicit_action.title = unsaved_title;
			
			edited_explicit_action_changed();
		}
		
		public void users_added_to_explicit_action(Gee.List<string> user_names) {
			var new_selected_account_properties = new ArrayList<AccountProperties>();
			var new_not_selected_account_properties = new ArrayList<AccountProperties>();
			
			foreach (var account_property in selected_account_properties) {
				new_selected_account_properties.add(account_property);
			}
			
			foreach (var account_property in not_selected_account_properties) {
				var match_found = false;
				foreach (var user_name in user_names) {
					if (account_property.user_name == user_name) {
						match_found = true;
						break;
					}
				}
				
				if (match_found) {
					new_selected_account_properties.add(account_property);
				}
				else {
					new_not_selected_account_properties.add(account_property);
				}
			}
			
			selected_account_properties = new_selected_account_properties;
			not_selected_account_properties = new_not_selected_account_properties;
		}
		
		public void users_removed_to_explicit_action(Gee.List<string> user_names) {
			var new_selected_account_properties = new ArrayList<AccountProperties>();
			var new_not_selected_account_properties = new ArrayList<AccountProperties>();
			
			foreach (var account_property in not_selected_account_properties) {
				new_not_selected_account_properties.add(account_property);
			}
			
			foreach (var account_property in selected_account_properties) {
				var match_found = false;
				foreach (var user_name in user_names) {
					if (account_property.user_name == user_name) {
						match_found = true;
						break;
					}
				}
				
				if (match_found) {
					new_not_selected_account_properties.add(account_property);
				}
				else {
					new_selected_account_properties.add(account_property);
				}
			}
			
			selected_account_properties = new_selected_account_properties;
			not_selected_account_properties = new_not_selected_account_properties;
		}
	}
}
