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
	public class ImplicitEditorView : Grid, IBaseView {
		private ComboBox allow_any_combobox;
		private ComboBox allow_active_combobox;
		private ComboBox allow_inactive_combobox;
		
		public signal void allow_any_index_changed(int index);
		public signal void allow_active_index_changed(int index);
		public signal void allow_inactive_index_changed(int index);
		
		public ImplicitEditorView() {
			GLib.Object (orientation: Gtk.Orientation.HORIZONTAL,
						 expand : true );
			init();
		}
		
		protected void init() {
			var allow_any_text_cell_rendere = new CellRendererText();
			var allow_active_text_cell_rendere = new CellRendererText();
			var allow_inactive_text_cell_rendere = new CellRendererText();
			allow_any_combobox = new ComboBox() {active = 0 };
			allow_active_combobox = new ComboBox() {active = 0 };
			allow_inactive_combobox = new ComboBox() {active = 0 };
			
			allow_any_combobox.hexpand = true;
			allow_active_combobox.hexpand = true;
			allow_inactive_combobox.hexpand = true;
			
			allow_any_combobox.pack_start(allow_any_text_cell_rendere, false);
			allow_active_combobox.pack_start(allow_active_text_cell_rendere, false);
			allow_inactive_combobox.pack_start(allow_inactive_text_cell_rendere, false);
			
			allow_any_combobox.set_attributes(allow_any_text_cell_rendere, "text", 0, null);
			allow_active_combobox.set_attributes(allow_active_text_cell_rendere, "text", 0, null);
			allow_inactive_combobox.set_attributes(allow_inactive_text_cell_rendere, "text", 0, null);
			
			allow_any_combobox.changed.connect((sender) => { allow_any_index_changed(allow_any_combobox.get_active()); });
			allow_active_combobox.changed.connect((sender) => { allow_active_index_changed(allow_active_combobox.get_active()); });
			allow_inactive_combobox.changed.connect((sender) => { allow_inactive_index_changed(allow_inactive_combobox.get_active()); });
			
			var allow_any_label = new Label("Allow any");
			allow_any_label.halign = Align.START;
			this.attach(allow_any_label, 0, 0, 1, 1);
			this.attach(allow_any_combobox, 1, 0, 1, 1);
			var allow_active_label = new Label("Allow active");
			allow_active_label.halign = Align.START;
			this.attach(allow_active_label, 0, 1, 1, 1);
			this.attach(allow_active_combobox, 1, 1, 1, 1);
			var allow_inactive_label = new Label("Allow inactive");
			allow_inactive_label.halign = Align.START;
			this.attach(allow_inactive_label, 0, 2, 1, 1);
			this.attach(allow_inactive_combobox, 1, 2, 1, 1);
		}
		
		public void connect_model(BaseModel base_model) {
			ImplicitEditorModel implicit_editor_model = (ImplicitEditorModel)base_model;
			allow_any_combobox.set_model(implicit_editor_model.implicit_authorization_list_store);
			allow_active_combobox.set_model(implicit_editor_model.implicit_authorization_list_store);
			allow_inactive_combobox.set_model(implicit_editor_model.implicit_authorization_list_store);
			
			// Bind view to model
			implicit_editor_model.bind("allow-any-index", allow_any_combobox, "active");
			implicit_editor_model.bind("allow-active-index", allow_active_combobox, "active");
			implicit_editor_model.bind("allow-inactive-index", allow_inactive_combobox, "active");
			
			// Bind model to events from view
			allow_any_index_changed.connect(implicit_editor_model.allow_any_authorization_changed);
			allow_active_index_changed.connect(implicit_editor_model.allow_active_authorization_changed);
			allow_inactive_index_changed.connect(implicit_editor_model.allow_inactive_authorization_changed);
		}
	}
}
