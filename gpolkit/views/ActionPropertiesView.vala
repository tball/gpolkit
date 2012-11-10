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
	public class ActionPropertiesView : Box, IBaseView {
		private Label action_vendor;
		private Label action_description;
		private Image action_icon;
		
		public string action_vendor_string {get; set; default = "";}
		public string action_vendor_url_string {get; set; default = "";}
		public ImplicitEditorView implicit_editor_view;
		public ExplicitOverviewView explicit_overview_view;
		public ActionPropertiesView() {
			GLib.Object (orientation: Gtk.Orientation.VERTICAL,
						 spacing: 4,
						 expand : false,
						 sensitive : false,
						 margin : 10);
			Init();
		}
		
		public void connect_model(BaseModel base_model) {
			// Internal bindings
			this.notify["action-vendor-string"].connect(vendor_markup_changed);
			this.notify["action-vendor-url-string"].connect(vendor_markup_changed);
			
			// Bind to the model properties
			base_model.bind_property("action-vendor", this, "action-vendor-string");
			base_model.bind_property("action-vendor-url", this, "action-vendor-url-string");
			base_model.bind_property("action-description", action_description, "label");
			base_model.bind_property("action-icon", action_icon, "icon-name");
			base_model.bind_property("action-is-valid", this, "sensitive");
			
			// Bind child views
			ActionPropertiesModel action_properties_model = base_model as ActionPropertiesModel;
			implicit_editor_view.connect_model(action_properties_model.implicit_editor_model);
			explicit_overview_view.connect_model(action_properties_model.explicit_overview_model);
		}
		
		protected void Init() {
			action_icon = new Image.from_icon_name("", IconSize.DIALOG);
			action_icon.notify["icon-name"].connect((sender, param) => { 
					action_icon.pixel_size = 50; 
				});

			action_description = new Label("");
			action_description.halign = Align.START;
			action_vendor = new Label("");
			action_vendor.halign = Align.START;
			implicit_editor_view = new ImplicitEditorView();
			explicit_overview_view = new ExplicitOverviewView();
			
			var horizontal_box = new Box(Orientation.HORIZONTAL, 4);
			var vertical_box = new Box(Orientation.VERTICAL, 4);
			vertical_box.pack_start(action_vendor, false);
			vertical_box.pack_start(action_description, false);
			horizontal_box.pack_start(action_icon, false);
			horizontal_box.pack_start(vertical_box, false);
			
			var implicit_label = new Label(null);
			implicit_label.halign = Align.START;
			implicit_label.set_markup("<b>Implicit action</b>");
			var explicit_label = new Label(null);
			explicit_label.halign = Align.START;
			explicit_label.set_markup("<b>Explicit action</b>");
			
			this.pack_start(horizontal_box, false);
			this.pack_start(implicit_label, false);
			this.pack_start(implicit_editor_view, false);
			this.pack_start(explicit_label, false);
			this.pack_start(explicit_overview_view, false);
		}
		
		public void vendor_markup_changed(Object sender, ParamSpec spec) {
			action_vendor.set_markup(("""<big><a href="%s" title="%s">%s...</a></big>""").printf(action_vendor_url_string, (action_vendor_url_string == "" ? "Url not available" : action_vendor_url_string), action_vendor_string));
		}
	}
}
