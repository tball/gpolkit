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
	public class ExplicitEditorWindowView : Window, IBaseView {
		private ImplicitEditorView implicit_editor_view;
		private UserSelectView user_select_view;
		private Button save_changes_button;
		private Button cancel_changes_button;
		private Entry action_title_entry;
	
		public signal void save_explicit_action(); 

		public ExplicitEditorWindowView() {
			GLib.Object( modal : true,
						 title : "Add / edit explicit action",
						 window_position : WindowPosition.CENTER,
						 height_request : 480,
						 width_request : 640);
			init();
		}
		
		protected void init() {
			var vertical_box = new Box(Orientation.VERTICAL, 4) { margin = 10 };
			var horizontal_box = new Box(Orientation.HORIZONTAL, 4);
			var title_label = new Label(null);
			var action_authentication_label = new Label(null);
			var user_select_label = new Label(null);
			implicit_editor_view = new ImplicitEditorView();
			user_select_view = new UserSelectView();
			save_changes_button = new Button.with_label("Save");
			cancel_changes_button = new Button.with_label("Cancel");
			action_title_entry = new Entry();
			user_select_label = new Label(null);
			
			
			title_label.halign = Align.START;
			title_label.set_markup("<b>Title</b>");
			action_authentication_label.halign = Align.START;
			action_authentication_label.set_markup("<b>Authentication</b>");
			user_select_label.halign = Align.START;
			user_select_label.set_markup("<b>Affected users</b>");
			
			save_changes_button.clicked.connect((sender) => { save_explicit_action(); destroy(); });
			cancel_changes_button.clicked.connect((sender) => { destroy(); });
			
			horizontal_box.pack_start(save_changes_button, false);
			horizontal_box.pack_start(cancel_changes_button, false);
			vertical_box.pack_start(title_label, false);
			vertical_box.pack_start(action_title_entry, false);
			vertical_box.pack_start(action_authentication_label, false);
			vertical_box.pack_start(implicit_editor_view, false);
			vertical_box.pack_start(user_select_label, false);
			vertical_box.pack_start(user_select_view);
			vertical_box.pack_start(horizontal_box, false);
			
			this.add(vertical_box);
		}

		void connect_model(BaseModel base_model) {
			var explicit_editor_window_model = base_model as ExplicitEditorWindowModel;
			explicit_editor_window_model.bind_property("title", action_title_entry, "text");
			action_title_entry.bind_property("text", explicit_editor_window_model, "unsaved-title");
			
			// Connect view events to model
			save_explicit_action.connect(explicit_editor_window_model.save_explicit_action);
			
			// Connect child views to child models
			implicit_editor_view.connect_model(explicit_editor_window_model.implicit_editor_model);
		}
	}
}
