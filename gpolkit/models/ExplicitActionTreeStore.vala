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

namespace GPolkit.Models {
	public class ExplicitActionTreeStore : TreeStore {
		public enum ColumnTypes {
			IDENTITY = 0,
			OBJECT
		}
	
		public ExplicitActionTreeStore() {
			set_column_types(new Type[] {typeof(string), typeof(GActionDescriptor)});
		}

		public void update_policies(GActionDescriptor? currently_selected_action, Gee.List<GActionDescriptor>? actions) {
			clear();
			
			if (currently_selected_action == null || actions == null) {
				return;
			}

			// Parse policies			
			foreach (GActionDescriptor action in actions) {
				if (!action.identity.contains(currently_selected_action.identity)) {
					continue;
				}

				TreeIter root;
				append(out root, null);
				set(root, ColumnTypes.IDENTITY, "<b>" + action.title + "</b>,\n<i>" + action.file_path + "</i>", ColumnTypes.OBJECT, action, -1);
			}
		}
	}
}
 
