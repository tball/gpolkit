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
using GPolkit.Views;


namespace GPolkit.Models {
	public class ActionListModel : BaseModel {
		private ActionListTreeStoreProxy action_list_tree_store_proxy;
		private BaseModel parent;
		
		public Gee.List<GActionDescriptor> implicit_actions { get; set; default = null; }
		public Gee.List<GActionDescriptor> currently_selected_actions { get; set; default = null; }
		public GActionDescriptor selected_explicit_action { get; set; default = null; }
		
		public ActionListModel(BaseModel parent_model) {
			parent = parent_model;
			init();
		}
		
		protected void init() {
			action_list_tree_store_proxy = new ActionListTreeStoreProxy();
			
			// Init internal connections
			this.notify["implicit-actions"].connect(action_list_tree_store_proxy.policies_changed);
			
			// Connect to appropriate parent model properties
			parent.bind_property("implicit-actions", this, "implicit-actions");
			parent.bind_property("search-string", action_list_tree_store_proxy, "filter-string");
			this.bind_property("currently-selected-actions", parent, "currently-selected-actions");
		}
		
		public TreeModel get_filtered_tree_model() {
			return action_list_tree_store_proxy.get_filtered_tree_model();
		}
		
		public void action_selection_changed(TreeSelection sender) {
			TreeModel tree_model;
			var selected_action_descriptors = new ArrayList<GActionDescriptor>();
			var selected_action_tree_paths = sender.get_selected_rows(out tree_model);
			
			foreach (var selected_action_tree_path in selected_action_tree_paths) {
				TreeIter tree_iter;
				Value action_descriptor_value;
				if (!tree_model.get_iter(out tree_iter, selected_action_tree_path)) {
					continue;
				}
				
				tree_model.get_value(tree_iter, ActionListTreeStoreProxy.ColumnTypes.ACTION_REF, out action_descriptor_value);
				var selected_action = action_descriptor_value.get_object() as GActionDescriptor;
				
				if (selected_action != null) {
					selected_action_descriptors.add(selected_action);
				}
			}
			currently_selected_actions = selected_action_descriptors;
		}
	}
}
