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
using GPolkit.Views;
 
 namespace GPolkit.Models {
	 public class MainWindowModel : BaseModel {
		 public IGPolkitHelper gpolkit_helper {get; set; default = null;}
		 public ActionListModel action_list_model;
		 public ActionPropertiesModel action_properties_model;
		 public TopToolbarModel top_toolbar_model;
		 public Gee.List<GActionDescriptor> implicit_actions {get; set; default = null;}
		 public Gee.List<GActionDescriptor> explicit_actions {get; set; default = null;}
		 public GActionDescriptor currently_selected_action { get; set; default = null;}
		 public string search_string { get; set; default = ""; }
		 
		 public MainWindowModel() {
			 init();
		 }
		 
		 protected void init() {
			 // init models
			 action_list_model = new ActionListModel(this);
			 action_properties_model = new ActionPropertiesModel(this);
			 top_toolbar_model = new TopToolbarModel(this);
			 
			 // Init authorization helper
			try {
				gpolkit_helper = Bus.get_proxy_sync (BusType.SYSTEM, "org.gnome.gpolkit.helper",
													"/org/gnome/gpolkit/helper");

			} catch (IOError e) {
				stderr.printf ("%s\n", e.message);
			}
			
			// Fetch policies
			HashTable<string,Variant>[] hash_tables;
			try {
				hash_tables = gpolkit_helper.get_implicit_policies ();
				implicit_actions = GActionDescriptor.de_serialize_array(hash_tables);
			}
			catch(IOError err) {
				stderr.printf("Unable to get implicit policies. Error %s\n", err.message);
			}
			
			try {
				hash_tables = gpolkit_helper.get_explicit_policies ();
				explicit_actions = GActionDescriptor.de_serialize_array(hash_tables);
				foreach (var exp_action in explicit_actions) {
					stdout.printf("Fetched explicit action %s\n", exp_action.to_string());
				}
			}
			catch(IOError err) {
				stderr.printf("Unable to get explicit policies. Error %s\n", err.message);
			}
		 }
		 
		 public void close() {
			Gtk.main_quit();
		}
	 }
}
