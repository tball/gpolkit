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
using Polkit;
using GPolkit.Common;

namespace GPolkit.Models {
	public class ExplicitActionTreeStore : TreeStore {
		public enum ColumnTypes {
			IDENTITY = 0,
			OBJECT
		}
	
		public ExplicitActionTreeStore() {
			set_column_types(new Type[] {typeof(string), typeof(GActionDescriptor)});
		}

		public void update_policies(Gee.List<GActionDescriptor>? currently_selected_actions, Gee.List<GActionDescriptor>? actions) {
			clear();
			
			if (currently_selected_actions == null || actions == null) {
				return;
			}
			
			if (currently_selected_actions.size < 1) {
				return;
			}

			// Parse policies			
			foreach (var action in actions) {
				var action_exists_for_selected_actions = true;
				foreach (var currently_selected_action in currently_selected_actions) {
					if (!action.identity.contains(currently_selected_action.identity)) {
						action_exists_for_selected_actions = false;
						break;
					}
				}
				
				if (!action_exists_for_selected_actions) {
					continue;
				}

				var allow_any_readable_string = ImplicitEditorModel.implicit_authorizations_string_array[GActionDescriptor.get_authorization_index_from_string(action.allow_any)];
				var allow_active_readable_string = ImplicitEditorModel.implicit_authorizations_string_array[GActionDescriptor.get_authorization_index_from_string(action.allow_active)];
				var allow_inactive_readable_string = ImplicitEditorModel.implicit_authorizations_string_array[GActionDescriptor.get_authorization_index_from_string(action.allow_inactive)];
				TreeIter root;
				append(out root, null);
				set(root, ColumnTypes.IDENTITY, "<b>" + action.title + "</b>, " + "(Allow any: " + allow_any_readable_string + ", Allow active: " + allow_active_readable_string + ", Allow inactive: " + allow_inactive_readable_string + ")\n" +
												"<i>" + action.user_names + "</i>\n"
												, ColumnTypes.OBJECT, action, -1);
			}
		}
	}
}
 
