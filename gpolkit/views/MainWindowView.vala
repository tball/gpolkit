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
	public class MainWindowView : Window, IBaseView {
		private Box horizontal_box;
		private Box vertical_box;
		
		public ActionListView action_list_view;
		public ActionPropertiesView action_properties_view;
		public TopToolbarView top_toolbar_view;
		public MainWindowView() {
			GLib.Object ( icon_name : "changes-prevent-symbolic",
						  title : "GPolkit authorization manager",
						  window_position : WindowPosition.CENTER,
						  width_request : 1024,
						  height_request : 768);
			init();
		}
		
		protected void init() {
			horizontal_box = new Box(Orientation.HORIZONTAL, 4);
			vertical_box = new Box(Orientation.VERTICAL, 4);
			action_list_view = new ActionListView();
			action_properties_view = new ActionPropertiesView();
			top_toolbar_view = new TopToolbarView();
			
			horizontal_box.pack_start(action_list_view);
			horizontal_box.pack_start(action_properties_view);
			vertical_box.pack_start(top_toolbar_view, false);
			vertical_box.pack_start(horizontal_box);
			this.add(vertical_box);
		}
		
		public void connect_model(BaseModel base_model) {
			MainWindowModel main_window_model = (MainWindowModel)base_model;
			
			// Connect childs views
			action_list_view.connect_model(main_window_model.action_list_model);
			action_properties_view.connect_model(main_window_model.action_properties_model);
			top_toolbar_view.connect_model(main_window_model.top_toolbar_model);
			
			// Connect signals
			this.destroy.connect(main_window_model.close);
		}
	}
}
