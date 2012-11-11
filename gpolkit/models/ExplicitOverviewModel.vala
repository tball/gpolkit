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
using GPolkit.Common;
using GPolkit.Views;

namespace GPolkit.Models {
	public class ExplicitOverviewModel : BaseModel {
		private BaseModel parent_model;
		
		public GActionDescriptor currently_selected_action { get; set; default = null; }
		public Gee.List<GActionDescriptor> explicit_actions { get; set; default = null; }
		public ExplicitActionTreeStore explicit_action_list_tree_store { get; set; default = null; }
		public bool can_add_or_edit_explicit_action { get; set; default = true; }
		
		public ExplicitOverviewModel(BaseModel parent) {
			parent_model = parent;
			init();
		}
		
		protected void init() {
			// Create child models
			explicit_action_list_tree_store = new ExplicitActionTreeStore();
			
			// Create internal bindings
			this.notify["currently-selected-action"].connect((object, sender) => {implicit_or_explicit_actions_changed();});
			this.notify["explicit-actions"].connect((object, sender) => {implicit_or_explicit_actions_changed();});
		}
		
		private void implicit_or_explicit_actions_changed()
		{
			explicit_action_list_tree_store.update_policies(currently_selected_action, explicit_actions);
		}
		
		public void add_or_edit_explicit_action(GActionDescriptor? edited_action) {
			can_add_or_edit_explicit_action = false;
			
			var explicit_editor_window_model = new ExplicitEditorWindowModel();
			var explicit_editor_window_view = new ExplicitEditorWindowView();
			
			explicit_editor_window_view.destroy.connect((sender) => { can_add_or_edit_explicit_action = true; });
			explicit_editor_window_view.connect_model(explicit_editor_window_model);
			explicit_editor_window_view.show_all();
			
			explicit_editor_window_model.edited_explicit_action_changed.connect((sender) => { implicit_or_explicit_actions_changed(); });
			explicit_editor_window_model.unsaved_explicit_action = edited_action;
		}
	}
}
