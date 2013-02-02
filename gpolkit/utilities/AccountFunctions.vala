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
 using Oobs;
 
 namespace GPolkit.Utilities {
 	public class AccountFunctions : GLib.Object {
		public static Gee.List<AccountProperties> get_all_accounts() {
			var all_accounts = new ArrayList<AccountProperties>();
			
			var user_accounts = get_users();
			var group_accounts = get_groups();
				
			all_accounts.add_all(user_accounts);
			all_accounts.add_all(group_accounts);
				
			return all_accounts;
		}
		
		public static Gee.List<AccountProperties> get_groups() {
			var groups = new ArrayList<AccountProperties>();
			var groups_config = GroupsConfig.get() as GroupsConfig;
			groups_config.update();
			
			var oobs_groups = groups_config.get_groups();
			if (oobs_groups == null) {
				return groups;
			}
			
			ListIter iter = ListIter();
			if (oobs_groups.get_iter_first(ref iter)) {
				do {
					var oobs_group = (Group)oobs_groups.get(iter);
					if (oobs_group.name != null && oobs_group.name != "") {
						groups.add(new AccountProperties() { user_name = oobs_group.name, full_name = oobs_group.name, account_type = AccountType.LINUX_GROUP });
					}
				} while(ListIter.next(oobs_groups, ref iter));
			}
			
			return groups;
		}
		
		public static Gee.List<AccountProperties> get_users() {
			var users = new ArrayList<AccountProperties>();
			var users_config = UsersConfig.get() as UsersConfig;
			users_config.update();
			
			var oobs_users = users_config.get_users();
			if (oobs_users == null) {
				return users;
			}
			
			ListIter user_iter = ListIter();
			if (oobs_users.get_iter_first(ref user_iter)) {
				do {
					var oobs_user = (User)oobs_users.get(user_iter);
					if (oobs_user.name != null && oobs_user.name != "") {
						users.add(new AccountProperties() { user_name = oobs_user.name, full_name = oobs_user.full_name, account_type = AccountType.LINUX_USER });
					}
				} while(ListIter.next(oobs_users, ref user_iter));
			}
			
			return users;
		}
	} 
}
