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
using GPolkit.Views;
using GPolkit.Models;

namespace GPolkit {
	class Program : Object {
		private IBaseView main_window_view = null;
		private BaseModel main_window_model = null;

		public Program( ) {
			/* Object( application_id: "gpolkit",
			        flags: ApplicationFlags.FLAGS_NONE );*/

		}

		public void setup_ui(string[] args) {
			Gtk.init (ref args);
			main_window_view = new MainWindowView();
			main_window_model = new MainWindowModel();
			main_window_view.connect_model(main_window_model);
			
			var main_window_view_window = main_window_view as Window;
			main_window_view_window.destroy.connect(Gtk.main_quit);
			main_window_view_window.show_all();
		}

		public void run() {
			Gtk.main();
		}
	}
}
