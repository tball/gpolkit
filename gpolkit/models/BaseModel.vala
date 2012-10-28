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
using GPolkit.Views;

namespace GPolkit.Models {
	public class ModelBindingDescription {
		public string src_path;
		public Object dest_obj;
		public string dest_path;
	}
	
	public class BaseModel : GLib.Object {
		private Gee.Collection<ModelBindingDescription> bindings = new Gee.ArrayList<ModelBindingDescription>();
		
		public BaseModel() {
			init_binding_engine();
		}
		
		protected void init_binding_engine() {
			this.notify.connect(model_property_changed);
		}
		
		public void bind(string src_path, GLib.Object dest_obj, string dest_path) {
			var model_binding_description = new ModelBindingDescription()
				{
					src_path = src_path,
					dest_obj = dest_obj,
					dest_path = dest_path								
				};
			bindings.add(model_binding_description);
		}
		
		public void model_property_changed(Object sender, ParamSpec src_spec) {
			Value src_value = Value(src_spec.value_type);
			sender.get_property(src_spec.name, ref src_value);
			
			foreach(var binding_description in bindings) {
				if (src_spec.name != binding_description.src_path) {
					continue;
				}
				binding_description.dest_obj.set_property(binding_description.dest_path, src_value);
			}
		}
	}
}
