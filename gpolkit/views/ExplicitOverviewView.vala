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
using GPolkit.Models;
 
namespace GPolkit.Views {
	public class ExplicitOverviewView : Box, IBaseView {
		private const string[] implicit_authorizations_string_array = {"Not authorized", "Authentication required", "Admin authentication required",
																	   "Authentication required retained", "Admin authentication required retained", "Authorized"};
		private TreeView explicit_action_tree_view;
		private ToolButton add_action_rule_button;
		private ToolButton remove_action_rule_button;
		
		public ListStore implicit_authorization_list_store { get; set; default = null; }
		public ExplicitOverviewView() {
			GLib.Object (orientation: Gtk.Orientation.VERTICAL);
			init();
		}
		
		private void init_list_store() {
			implicit_authorization_list_store = new ListStore.newv(new Type[] {typeof(string)});
			
			foreach(var str in implicit_authorizations_string_array) {
				TreeIter iter;
				implicit_authorization_list_store.append(out iter);
				implicit_authorization_list_store.set(iter, 0, str, -1);
			}
		}
		
		protected void init() {
			init_list_store();
			
			explicit_action_tree_view = new TreeView() { expand = true, headers_visible = false };
			var action_toolbar = new Toolbar();
			var scrolled_window = new ScrolledWindow(null, null) { expand = true, shadow_type = ShadowType.IN };
			add_action_rule_button = new ToolButton(null, null);
			remove_action_rule_button = new ToolButton(null, null);
			
			// Init treeview
			var title_text_cell_renderer = new CellRendererText();
			var action_any_combo_cell_renderer = new CellRendererCombo();
			action_any_combo_cell_renderer.model = implicit_authorization_list_store;
			var tree_view_column = new TreeViewColumn();
			
			//vertical_box.pack_start(title_text_cell_renderer);
			//vertical_box.pack_start(info_text_cell_renderer);
			
			tree_view_column.pack_start(title_text_cell_renderer, false);
			tree_view_column.pack_start(action_any_combo_cell_renderer, false);
			tree_view_column.set_attributes(title_text_cell_renderer, "markup", 0, null);
			//tree_view_column.set_attributes(action_combo_cell_renderer, "text", 1, null);
			explicit_action_tree_view.append_column(tree_view_column);
			
			//action_toolbar.get_style_context().set_junction_sides(JunctionSides.TOP);
			//explicit_action_tree_view.get_style_context().set_junction_sides(JunctionSides.BOTTOM);
			add_action_rule_button.icon_name = "list-add-symbolic";
			remove_action_rule_button.icon_name = "list-remove-symbolic";
			add_action_rule_button.clicked.connect(add_action_rule_button_clicked);
			
			action_toolbar.insert(add_action_rule_button, 0);
			action_toolbar.insert(remove_action_rule_button, 1);
			
			scrolled_window.add(explicit_action_tree_view);
			this.pack_start(scrolled_window);
			this.pack_start(action_toolbar, false);
		}
		
		public void connect_model(BaseModel base_model) {
			var explicit_overview_model = base_model as ExplicitOverviewModel;
			explicit_overview_model.bind_property("explicit-action-list-tree-store", explicit_action_tree_view, "model");
			explicit_action_tree_view.model = explicit_overview_model.explicit_action_list_tree_store;
		}
		
		private void add_action_rule_button_clicked(ToolButton sender) {
			add_action_rule_button.sensitive = false;
			remove_action_rule_button.sensitive = false;
			
			var explicit_editor_window_view = new ExplicitEditorWindowView();
			explicit_editor_window_view.destroy.connect(explicit_editor_window_view_destroy);
			((Window)explicit_editor_window_view).show_all();
		}
		
		private void explicit_editor_window_view_destroy(Widget sender) {
			var explicit_editor_window_view = sender as  ExplicitEditorWindowView;
			
			if (explicit_editor_window_view.save_changes) {
				stdout.printf("Saving changes\n");
			}
			else {
				stdout.printf("Skipping changes\n");
			}
			
			add_action_rule_button.sensitive = true;
			remove_action_rule_button.sensitive = true;
		}
	}
}
