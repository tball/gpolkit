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
using GPolkit.Common;

namespace GPolkit.Models {
	public class ExplicitEditorWindowModel : BaseModel {
		public GActionDescriptor edited_authorizations { get; set; default = null; }
		public GActionDescriptor unsaved_explicit_action { get; set; default = null; }
		public string title { get; set; default = null; }
		public string identity { get; set; default = null; }
		public string unsaved_title { get; set; default = null; }
		public ImplicitEditorModel implicit_editor_model;
		
		public signal void edited_explicit_action_changed();
		
		public ExplicitEditorWindowModel() {
			init();
		}
		
		protected void init() {
			// Init internal bindings
			this.notify["unsaved-explicit-action"].connect(unsaved_explicit_action_changed);
			
			// Init model children
			implicit_editor_model = new ImplicitEditorModel(this);
			
			// Bind child models
			this.bind_property("edited-authorizations", implicit_editor_model, "edited-implicit-action");
		}
		
		public void unsaved_explicit_action_changed(Object sender, ParamSpec spec) {
			if (unsaved_explicit_action == null) {
				title = "";
				return;
			}
			
			var implicit_edited_action = new GActionDescriptor(null);
			implicit_edited_action.copy_from(unsaved_explicit_action);
			edited_authorizations = implicit_edited_action;
			
			title = unsaved_explicit_action.title;
		}
		
		public void save_explicit_action() {
			unsaved_explicit_action.copy_from(edited_authorizations);
			unsaved_explicit_action.title = unsaved_title;
			
			edited_explicit_action_changed();
		}
	}
}
