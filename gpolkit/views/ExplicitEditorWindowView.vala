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
using GPolkit.Models;
using GPolkit.Utilities;
 
namespace GPolkit.Views {
	public class ExplicitEditorWindowView : Window, IBaseView {
		private ImplicitEditorView implicit_editor_view;
		private Button save_changes_button;
		private Button cancel_changes_button;
		private Entry action_title_entry;
		private TreeView selected_user_tree_view;
		private TreeView not_selected_user_tree_view;
		private Button add_user_button;
		private Button remove_user_button;
	
		public signal void save_explicit_action(); 
		public signal void users_added_to_explicit_action(Gee.List<string> user_names); 
		public signal void users_removed_to_explicit_action(Gee.List<string> user_names); 

		public ExplicitEditorWindowView() {
			GLib.Object( modal : true,
						 title : "Add / Edit Explicit Action",
						 window_position : WindowPosition.CENTER,
						 height_request : 480,
						 width_request : 640);
			init();
		}
		
		protected void init() {
			var vertical_box = new Box(Orientation.VERTICAL, 4) { margin = 10 };
			var horizontal_box = new Box(Orientation.HORIZONTAL, 4);
			var horizontal_user_select_box = new Box(Orientation.HORIZONTAL, 4);
			var vertical_select_buttons_box = new Box(Orientation.VERTICAL, 4) { margin = 4 };
			var title_label = new Label(null);
			var action_authentication_label = new Label(null);
			var selected_user_scrolled_window = new ScrolledWindow(null, null);
			var not_selected_user_scrolled_window = new ScrolledWindow(null, null);
			var user_select_image = new Image.from_stock(Stock.GO_FORWARD, IconSize.BUTTON);
			var user_unselect_image = new Image.from_stock(Stock.GO_BACK, IconSize.BUTTON);
			add_user_button = new Button() { image = user_select_image };
			remove_user_button = new Button() { image = user_unselect_image };
			var add_remove_user_buttons_alignment = new Alignment(0.5f, 0.5f, 0.0f, 0.0f);
			
			selected_user_tree_view = new TreeView();
			selected_user_tree_view.get_selection().mode = SelectionMode.MULTIPLE;
			not_selected_user_tree_view = new TreeView();
			not_selected_user_tree_view.get_selection().mode = SelectionMode.MULTIPLE;
			implicit_editor_view = new ImplicitEditorView();
			save_changes_button = new Button.with_label("Save");
			cancel_changes_button = new Button.with_label("Cancel");
			action_title_entry = new Entry();
			
			// Init tree view
			var selected_user_text_cell_rendere = new CellRendererText();
			var not_selected_user_text_cell_rendere = new CellRendererText();
			var selected_user_tree_view_column = new TreeViewColumn() { title = "Selected Users" };
			var not_selected_user_tree_view_column = new TreeViewColumn() { title = "Available Users" };
			
			selected_user_tree_view_column.pack_start(selected_user_text_cell_rendere, false);
			selected_user_tree_view_column.set_attributes(selected_user_text_cell_rendere, "markup", UserListTreeStore.ColumnTypes.NAME, "sensitive", UserListTreeStore.ColumnTypes.SELECTABLE, null);
			
			not_selected_user_tree_view_column.pack_start(not_selected_user_text_cell_rendere, false);
			not_selected_user_tree_view_column.set_attributes(not_selected_user_text_cell_rendere, "markup", UserListTreeStore.ColumnTypes.NAME, "sensitive", UserListTreeStore.ColumnTypes.SELECTABLE, null);
			
			selected_user_tree_view.append_column(selected_user_tree_view_column);
			not_selected_user_tree_view.append_column(not_selected_user_tree_view_column);
			
			title_label.halign = Align.START;
			title_label.set_markup("<b>Title</b>");
			action_authentication_label.halign = Align.START;
			action_authentication_label.set_markup("<b>Authentication</b>");
			
			save_changes_button.clicked.connect((sender) => { save_explicit_action(); destroy(); });
			cancel_changes_button.clicked.connect((sender) => { destroy(); });
			add_user_button.clicked.connect((sender) => { add_user_button_clicked(); });
			remove_user_button.clicked.connect((sender) => { remove_user_button_clicked(); });
			
			vertical_select_buttons_box.pack_start(add_user_button, false);
			vertical_select_buttons_box.pack_start(remove_user_button, false);
			add_remove_user_buttons_alignment.add(vertical_select_buttons_box);
			selected_user_scrolled_window.add(selected_user_tree_view);
			not_selected_user_scrolled_window.add(not_selected_user_tree_view);
			horizontal_box.pack_start(save_changes_button, false);
			horizontal_box.pack_start(cancel_changes_button, false);
			horizontal_user_select_box.pack_start(not_selected_user_scrolled_window, true);
			horizontal_user_select_box.pack_start(add_remove_user_buttons_alignment, false);
			horizontal_user_select_box.pack_start(selected_user_scrolled_window, true);
			vertical_box.pack_start(title_label, false);
			vertical_box.pack_start(action_title_entry, false);
			vertical_box.pack_start(action_authentication_label, false);
			vertical_box.pack_start(implicit_editor_view, false);
			vertical_box.pack_start(horizontal_user_select_box, true);
			vertical_box.pack_start(horizontal_box, false);
			
			this.add(vertical_box);
		}

		public void connect_model(BaseModel base_model) {
			var explicit_editor_window_model = base_model as ExplicitEditorWindowModel;
			explicit_editor_window_model.bind_property("title", action_title_entry, "text");
			action_title_entry.bind_property("text", explicit_editor_window_model, "unsaved-title");
			
			// Connect view events to model
			save_explicit_action.connect(explicit_editor_window_model.save_explicit_action);
			users_added_to_explicit_action.connect(explicit_editor_window_model.users_added_to_explicit_action);
			users_removed_to_explicit_action.connect(explicit_editor_window_model.users_removed_to_explicit_action);
			
			// Connect and bind child views to child models
			implicit_editor_view.connect_model(explicit_editor_window_model.implicit_editor_model);
			not_selected_user_tree_view.model = explicit_editor_window_model.not_selected_user_list_tree_store;
			selected_user_tree_view.model = explicit_editor_window_model.selected_user_list_tree_store;
			
		}
		
		public void add_user_button_clicked() {
			var added_user_names = get_selected_user_names_from_tree_view(not_selected_user_tree_view);
			if (added_user_names.size <= 0) {
				return;
			}
			
			users_added_to_explicit_action(added_user_names);
		}
		
		public void remove_user_button_clicked() {
			var removed_user_names = get_selected_user_names_from_tree_view(selected_user_tree_view);
			if (removed_user_names.size <= 0) {
				return;
			}
			
			users_removed_to_explicit_action(removed_user_names);
		}
		
		private Gee.List<string> get_selected_user_names_from_tree_view(TreeView tree_view) {
			var selected_user_names = new ArrayList<string>();
			
			// Get the selected 'unselected' users and move it to the 'selected' users
			TreeModel tree_model;
			var selected_tree_paths = tree_view.get_selection().get_selected_rows(out tree_model);
		
			foreach (var tree_path in selected_tree_paths) {
				TreeIter tree_iter;
				if (!tree_model.get_iter(out tree_iter, tree_path)) {
					continue;
				}
				
				Value user_name_value;
				tree_model.get_value(tree_iter, UserListTreeStore.ColumnTypes.OBJECT, out user_name_value);
				
				var account_property = user_name_value.get_object() as AccountProperties;
				selected_user_names.add(account_property.user_name);
			}
			
			return selected_user_names;
		}
	}
}
