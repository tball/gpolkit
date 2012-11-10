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
		
		public bool save_changes = false;

		public ExplicitEditorWindowView() {
			GLib.Object( modal : true,
						 title : "Add / edit explicit action",
						 window_position : WindowPosition.CENTER,
						 height_request : 480,
						 width_request : 640);
			init();
		}
		
		protected void init() {
			var vertical_box = new Box(Orientation.VERTICAL, 4);
			var horizontal_box = new Box(Orientation.HORIZONTAL, 4);
			implicit_editor_view = new ImplicitEditorView();
			user_select_view = new UserSelectView();
			save_changes_button = new Button.with_label("Save");
			cancel_changes_button = new Button.with_label("Cancel");
			
			save_changes_button.clicked.connect((sender) => { save_changes = true; destroy(); });
			cancel_changes_button.clicked.connect((sender) => { save_changes = false; destroy(); });
			
			horizontal_box.pack_start(save_changes_button);
			horizontal_box.pack_start(cancel_changes_button);
			vertical_box.pack_start(implicit_editor_view);
			vertical_box.pack_start(user_select_view);
			vertical_box.pack_start(horizontal_box);
			
			this.add(vertical_box);
		}

		void connect_model(BaseModel base_model) {
			
		}
	}
}
