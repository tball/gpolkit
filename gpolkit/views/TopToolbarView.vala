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
	public class TopToolbarView : Box, IBaseView {
		private Entry search_entry;
		private Button save_button;
		
		public signal void search_string_changed(string search_string);
		public signal void save_change_button_clicked();
		
		public TopToolbarView() {
			GLib.Object (orientation: Gtk.Orientation.HORIZONTAL,
						 spacing: 4,
						 expand : false );
			init();
		}
		
		protected void init() {
			search_entry = new Entry();
			save_button = new Button();
			
			search_entry.changed.connect((sender) => { search_string_changed(search_entry.text); });
			save_button.clicked.connect((sender) => { save_change_button_clicked(); });
			search_entry.secondary_icon_stock = "gtk-find";
			save_button.height_request = 35;
			save_button.width_request = 35;
			save_button.set_image(new Image.from_stock("gtk-save", IconSize.BUTTON));
			
			this.add(save_button);
			this.add(search_entry);
		}
		
		public void connect_model(BaseModel base_model) {
			TopToolbarModel top_toolbar_model = (TopToolbarModel)base_model;
			
			// Bind to the model properties
			search_string_changed.connect(top_toolbar_model.search_string_changed);
			save_change_button_clicked.connect(top_toolbar_model.save_changes);
		}
	}
}
