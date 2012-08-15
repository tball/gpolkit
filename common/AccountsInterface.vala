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

namespace GPolkit.Common {
	[DBus (name = "org.freedesktop.DBus.Properties")]
	public interface AccountPropertiesInterface : Object {
		public abstract HashTable<string, Variant> get_all(string interface_name) throws IOError;
	}
	
	[DBus (name = "org.freedesktop.Accounts")]
	public interface AccountsInterface : Object {
		public abstract ObjectPath[] list_cached_users() throws IOError;
		public abstract ObjectPath find_user_by_name(string username) throws IOError;
	}
}
