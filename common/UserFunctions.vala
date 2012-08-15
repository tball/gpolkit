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
 
 namespace GPolkit.Common
 {
 	public class UserProperties
 	{
 		public string real_name {get; set; default="";}
 		public string user_name {get; set; default="";}
 		public string icon_file {get; set; default="";}
 	}
 	
 	public class UserFunctions
 	{
 		private static AccountsInterface _accounts = null;
 		public static AccountsInterface accounts
 		{
 			get	{
 				try	{
 					if (_accounts == null) {
 					 	_accounts = Bus.get_proxy_sync (BusType.SYSTEM,
 														"org.freedesktop.Accounts",
														"/org/freedesktop/Accounts");
					}
				}
				catch(IOError err) {
						stderr.printf ("Unable to create accounts dbus proxy. Error: %s\n", err.message);
 				}
 				return _accounts;
 			}
 		
 		}
 		
 		public static AccountPropertiesInterface account_properties(string object_path)
 		{
 			AccountPropertiesInterface account_properties = null;
 			try	{
 				account_properties = Bus.get_proxy_sync(BusType.SYSTEM,
 													    "org.freedesktop.Accounts",
														object_path);
			}
			catch(IOError err) {
				stderr.printf("Unable to create accounts properties dbus proxy. Error: %s\n", err.message);
			}
			
 			return account_properties;
 		}
 	
 		public static UserProperties? get_user_properties(string object_path)
 		{
 			HashTable<string, Variant> user_hash;
 			try {
 				user_hash = account_properties(object_path).get_all("org.freedesktop.Accounts.User");
 			}
 			catch(IOError err) {
 				stderr.printf("Unable to fetch cached users. Error %s\n", err.message);
 				return null;
 			}
 			
 			// Parse the hash
 			Variant real_name = user_hash["RealName"];
 			Variant user_name = user_hash["UserName"];
 			Variant icon_file = user_hash["IconFile"];
 			if (user_name != null) {
 				return new UserProperties() { user_name = user_name.get_string(), real_name = real_name.get_string(), icon_file = icon_file.get_string() };
 			}
 			else {
 				return null;
 			}
 		}
 		
 		public static ObjectPath? get_user_path_from_username(string username)
 		{
 			if (accounts == null) {
				return null;
			}
			
			ObjectPath user_path;
			try {
				user_path = accounts.find_user_by_name(username);
			}
			catch(IOError err) {
				stderr.printf("Unable to get user path. Error: %s\n", err.message);
				return null;
			}
			
			return user_path;
 		}
 		
 		public static ObjectPath[]? get_users()
 		{
			if (accounts == null) {
				return null;
			}
			
			ObjectPath[] user_paths;
			try {
				user_paths = accounts.list_cached_users();
			}
			catch(IOError err) {
				stderr.printf("Unable to get user paths. Error: %s\n", err.message);
				return null;
			}
			
			return user_paths;
 		}
 	} 
 }
