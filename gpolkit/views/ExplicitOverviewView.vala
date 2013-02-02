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
using GPolkit.Models;
 
namespace GPolkit.Views {
	public class ExplicitOverviewView : Box, IBaseView {
		private TreeView explicit_action_tree_view;
		private ToolButton add_action_rule_button;
		private ToolButton remove_action_rule_button;
		
		public signal void action_added_or_edited_rule_button_clicked(GActionDescriptor? edited_action);
		
		public ExplicitOverviewView() {
			GLib.Object (orientation: Gtk.Orientation.VERTICAL);
			init();
		}
		
		protected void init() {
			explicit_action_tree_view = new TreeView() { expand = true, headers_visible = false };
			var action_toolbar = new Toolbar();
			var scrolled_window = new ScrolledWindow(null, null) { expand = true, shadow_type = ShadowType.IN };
			add_action_rule_button = new ToolButton(null, null);
			remove_action_rule_button = new ToolButton(null, null);
			
			// Init treeview
			var title_text_cell_renderer = new CellRendererText();
			var tree_view_column = new TreeViewColumn();
			
			tree_view_column.pack_start(title_text_cell_renderer, false);
			tree_view_column.set_attributes(title_text_cell_renderer, "markup", 0, null);
			explicit_action_tree_view.append_column(tree_view_column);

			add_action_rule_button.icon_name = "list-add-symbolic";
			remove_action_rule_button.icon_name = "list-remove-symbolic";
			
			// Create view bindings
			add_action_rule_button.clicked.connect((sender) => { action_added_or_edited_rule_button_clicked(null); });
			explicit_action_tree_view.row_activated.connect(explicit_action_selection_double_clicked);

			action_toolbar.insert(add_action_rule_button, 0);
			action_toolbar.insert(remove_action_rule_button, 1);
			
			scrolled_window.add(explicit_action_tree_view);
			this.pack_start(scrolled_window);
			this.pack_start(action_toolbar, false);
		}
		
		private void explicit_action_selection_double_clicked(TreeView tree_view, TreePath path, TreeViewColumn column) {
			TreeModel tree_model;
			TreeIter tree_iter;
			tree_view.get_selection().get_selected(out tree_model, out tree_iter);
			
			Value action_descriptor_value;
			tree_model.get_value(tree_iter, ExplicitActionTreeStore.ColumnTypes.OBJECT, out action_descriptor_value);
			var selected_action = action_descriptor_value.get_object() as GActionDescriptor;
			
			if (selected_action != null) {
				action_added_or_edited_rule_button_clicked(selected_action);
			}
		}
		
		public void connect_model(BaseModel base_model) {
			var explicit_overview_model = base_model as ExplicitOverviewModel;
			explicit_overview_model.bind_property("explicit-action-list-tree-store", explicit_action_tree_view, "model");
			explicit_overview_model.bind_property("can-add-or-edit-explicit-action", this, "sensitive");
			explicit_action_tree_view.model = explicit_overview_model.explicit_action_list_tree_store;
			
			// Connect view events to model
			explicit_action_tree_view.get_selection().changed.connect(explicit_overview_model.explicit_action_selection_changed);
			action_added_or_edited_rule_button_clicked.connect(explicit_overview_model.add_or_edit_explicit_action);
		}
	}
}
