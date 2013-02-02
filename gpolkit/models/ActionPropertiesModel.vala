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
 
 using GPolkit.Common;

namespace GPolkit.Models {
	public class ActionPropertiesModel : BaseModel {
		private BaseModel parent_model;
		public ImplicitEditorModel implicit_editor_model;
		public ExplicitOverviewModel explicit_overview_model;
		public Gee.List<GActionDescriptor> currently_selected_actions { get; set; default = null; }
		public GActionDescriptor selected_explicit_action { get; set; default = null; }
		public Gee.List<GActionDescriptor> explicit_actions { get; set; default = null; }
		public string action_vendor {get; set; default = ""; }
		public string action_vendor_url {get; set; default = ""; }
		public string action_description {get; set; default = ""; }
		public string action_icon {get; set; default = ""; }
		public bool action_is_valid { get; set; default = false; }
		
		public ActionPropertiesModel(BaseModel parent) {
			parent_model = parent;
			init();
		}
		
		protected void init() {
			// init child models
			implicit_editor_model = new ImplicitEditorModel(this);
			explicit_overview_model = new ExplicitOverviewModel(this);
			
			// Init internal connections
			this.notify["currently-selected-actions"].connect(currently_selected_actions_changed);
			
			// Connect to child models
			this.bind_property("currently-selected-actions", explicit_overview_model, "currently-selected-actions");
			this.bind_property("explicit-actions", explicit_overview_model, "explicit-actions");
			explicit_overview_model.bind_property("selected-explicit-action", this, "selected_explicit_action");
		}
		
		public void currently_selected_actions_changed(Object sender, ParamSpec spec) {
			if (currently_selected_actions == null) {
				stdout.printf("ActionPropertiesModel: selected actions null\n");
				action_vendor = "";
				action_vendor_url = "";
				action_description = "";
				action_icon = "";
				return;
			}
			
			if (currently_selected_actions.size == 1) {
				var currently_selected_action = currently_selected_actions.first();
				action_description = currently_selected_action.description;
				action_vendor = currently_selected_action.vendor;
				action_vendor_url = currently_selected_action.vendor_url;
				action_icon = currently_selected_action.icon_name;
				action_is_valid = true;
				implicit_editor_model.edited_implicit_action = currently_selected_action;
			}
			else {
				implicit_editor_model.edited_implicit_action = null;
			}
		}
	}
}
