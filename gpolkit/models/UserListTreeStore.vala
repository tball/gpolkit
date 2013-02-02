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
using GPolkit.Utilities;

namespace GPolkit.Models {
	public class UserListTreeStore : TreeStore {
		public Gee.List<AccountProperties> account_properties { get; set; default = null; }
		
		public enum ColumnTypes {
			NAME = 0,
			OBJECT,
			SELECTABLE
		}
	
		public UserListTreeStore() {
			set_column_types(new Type[] {typeof(string), typeof(Object), typeof(bool)});
			init();
		}
		
		protected void init() {
			// Create internal bindings
			this.notify["account-properties"].connect((sender) => { update_list(); });
		}

		public void update_list() {
			clear();
			
			if (account_properties == null) {
				return;
			}

			// Parse policies	
			TreeIter iter;
			append(out iter, null);
			set(iter, ColumnTypes.NAME, "<small><span foreground=\"#555555\">Users</span></small>", ColumnTypes.SELECTABLE, false, -1);
			foreach (AccountProperties account_property in account_properties) {
				if (account_property.account_type == AccountType.LINUX_GROUP) {
					continue;
				}
				
				append(out iter, null);
				set(iter, ColumnTypes.NAME, "<b>" + account_property.full_name + "</b>\n<i>" + account_property.user_name + "</i>", ColumnTypes.OBJECT, account_property, ColumnTypes.SELECTABLE, true, -1);
			}
			
			append(out iter, null);
			set(iter, ColumnTypes.NAME, "<small><span foreground=\"#555555\">Groups</span></small>", ColumnTypes.SELECTABLE, false, -1);
			foreach (AccountProperties account_property in account_properties) {
				if (account_property.account_type == AccountType.LINUX_USER) {
					continue;
				}
				
				append(out iter, null);
				set(iter, ColumnTypes.NAME, "<b>" + account_property.user_name + "</b>", ColumnTypes.OBJECT, account_property, ColumnTypes.SELECTABLE, true, -1);
			}
		}
	}
}
 
