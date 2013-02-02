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
	public class ImplicitEditorModel : BaseModel {
		public static const string[] implicit_authorizations_string_array = {"Not authorized", "Authentication required", "Admin authentication required",
																	   "Authentication required retained", "Admin authentication required retained", "Authorized"};
		private BaseModel parent_model;
		
		public GActionDescriptor edited_implicit_action { get; set; default = null; }
		public ListStore implicit_authorization_list_store { get; set; default = null; }
		public bool sensitive { get; set; default = true; }
		public int allow_any_index  { get; set; default = 0; }
		public int allow_active_index  { get; set; default = 0; }
		public int allow_inactive_index  { get; set; default = 0; }
		
		public ImplicitEditorModel(BaseModel parent) {
			parent_model = parent;
			init();
		}
		
		private void init_list_store() {
			implicit_authorization_list_store = new ListStore.newv(new Type[] {typeof(string)});
			
			foreach(var str in implicit_authorizations_string_array) {
				TreeIter iter;
				implicit_authorization_list_store.append(out iter);
				implicit_authorization_list_store.set(iter, 0, str, -1);
			}
		}
		
		protected void init() {
			init_list_store();
			
			// Internal bindings
			this.notify["edited-implicit-action"].connect(edited_implicit_action_changed);
		}
		
		public void edited_implicit_action_changed(Object sender, ParamSpec spec) {
			if (edited_implicit_action == null) {
				sensitive = false;
				return;
			}
			sensitive = true;
			
			// Register authorization indexes
			allow_any_index = GActionDescriptor.get_authorization_index_from_string(edited_implicit_action.allow_any);
			allow_active_index = GActionDescriptor.get_authorization_index_from_string(edited_implicit_action.allow_active);
			allow_inactive_index = GActionDescriptor.get_authorization_index_from_string(edited_implicit_action.allow_inactive);
		}
		
		public void allow_any_authorization_changed(int index) {
			var allow_any_str = GActionDescriptor.get_authorization_string_from_index(index);
			edited_implicit_action.allow_any = allow_any_str;
			edited_implicit_action.changed = "true";
		}
		
		public void allow_active_authorization_changed(int index) {
			var allow_active_str = GActionDescriptor.get_authorization_string_from_index(index);
			edited_implicit_action.allow_active = allow_active_str;
			edited_implicit_action.changed = "true";
		}
		
		public void allow_inactive_authorization_changed(int index) {
			var allow_inactive_str = GActionDescriptor.get_authorization_string_from_index(index);
			edited_implicit_action.allow_inactive = allow_inactive_str;
			edited_implicit_action.changed = "true";
		}
	}
}
