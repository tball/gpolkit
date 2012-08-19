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
using GPolkit.Common;

namespace GPolkit.Gui
{
     enum UserListColums {
          FULL_NAME_COL,
          IS_USER_COL,
          IS_GROUP_COL,
          FACE_COL
     }
     
     public class ActionWindow : Object {
          
          public Window view { get; set; default = null;} 
          public TreeView list_users { get; set; default = null;} 
          
          private Window build_ui() {
			var builder = new Builder();
			try {
				builder.add_from_file(Ressources.DATA_DIR + """/ActionWindow.glade""");
			}
			catch(Error e) {
				stdout.printf("Error compiling the ActionWindow.glade: %s\n", e.message);
			}

			var window = builder.get_object("user_window") as Window;


			// Fetch fields from ui
			list_users = builder.get_object("treeview_users") as TreeView;

			// Connect signals
			builder.connect_signals(this);

			return window;
		  }
          
          private void init() {
			
		  }
		  
          
          public ActionWindow() {
               // Load ui file
			this.view = build_ui();

			// Init
			init();
          }
     }
}
