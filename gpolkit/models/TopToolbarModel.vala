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
 
using Gee;
using GPolkit.Common;
 
namespace GPolkit.Models {
	public class TopToolbarModel : BaseModel {
		private BaseModel parent_model;
		
		public IGPolkitHelper gpolkit_helper {get; set; default = null;}
		public Gee.List<GActionDescriptor> implicit_actions {get; set; default = null;}
		public Gee.List<GActionDescriptor> explicit_actions {get; set; default = null;}
		public string search_string {get; set; default = "";}
		
		public TopToolbarModel(BaseModel parent) {
			parent_model = parent;
			init();
		}
		
		protected void init() {
			// Create bindings
			parent_model.bind_property("implicit-actions", this, "implicit-actions");
			parent_model.bind_property("gpolkit-helper", this, "gpolkit-helper");
			this.bind_property("search-string", parent_model, "search-string");
		}
		
		public void save_changes() {
			if (gpolkit_helper == null) {
				stderr.printf("TopToolbarModel: Could not save implicit policies, since the helper is not initialized.\n");
				return;
			}
			
			var changed_actions = new ArrayList<GActionDescriptor>();
			foreach(var action in implicit_actions) {
				if (action.changed == "true") {
					changed_actions.add(action);
				}
			}
			
			var hashes = GActionDescriptor.serialize_array(changed_actions);
			
			try {
				gpolkit_helper.set_implicit_policies(hashes);
			}
			catch(IOError err) {
				stderr.printf("TopToolbarModel: Could not save the implicit policies. Error %s\n", err.message);
			}
		}
		
		public void search_string_changed(string search_string) {
			this.search_string = search_string;
		}
	}
}
