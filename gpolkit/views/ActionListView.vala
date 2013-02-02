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
 using GPolkit.Models;
 using GPolkit.Common;
 
 namespace GPolkit.Views {
	 public class ActionListView : ScrolledWindow, IBaseView {
		 private TreeView tree_view;
		 
		 public ActionListView() {
			 GLib.Object (width_request : 80,
						  shadow_type : ShadowType.IN,
						  margin : 10);
			 init();
		 }
		 
		 public void connect_model(BaseModel base_model) {
			ActionListModel action_list_model = (ActionListModel)base_model;
			
			// Bind view to model
			tree_view.set_model(action_list_model.get_filtered_tree_model());
			
			// Bind model events to view
			action_list_model.notify["selected-explicit-action"].connect(selected_explicit_action_changed);
			
			// Bind model to events from view
			tree_view.get_selection().changed.connect(action_list_model.action_selection_changed);
		}
		
		protected void init() {
			this.expand = true;
			
			var pixbuf_cell_rendere = new CellRendererPixbuf();
			var text_cell_rendere = new CellRendererText();
			var tree_view_column = new TreeViewColumn();
			
			tree_view_column.pack_start(pixbuf_cell_rendere, false);
			tree_view_column.pack_start(text_cell_rendere, false);
			tree_view_column.set_attributes(pixbuf_cell_rendere, "icon_name", 0, null);
			tree_view_column.set_attributes(text_cell_rendere, "text", 1, null);
			tree_view_column.title = "Actions";
			tree_view = new TreeView();
			tree_view.get_selection().mode = SelectionMode.MULTIPLE;
			tree_view.expand = true;
			tree_view.append_column(tree_view_column);
			
			this.add(tree_view);
		}
		
		private void selected_explicit_action_changed(Object prop, ParamSpec spec) {
			Value prop_value = Value(spec.value_type);
			prop.get_property(spec.name, ref prop_value);

			var explicit_action = prop_value.get_object() as GActionDescriptor;
			var selection = tree_view.get_selection();
			var tree_model = tree_view.get_model();

			select_explicit_action_members(tree_model, selection, explicit_action, null);
		}
		
		private void select_explicit_action_members(TreeModel tree_model, TreeSelection tree_selection, GActionDescriptor explicit_action, TreeIter? parent) {
			TreeIter tree_iter;
			if (!tree_model.iter_children(out tree_iter, parent)) {
				return;
			}
			
			do {
				Value current_action_value;
				tree_model.get_value(tree_iter, ActionListTreeStoreProxy.ColumnTypes.ACTION_REF, out current_action_value);
				GActionDescriptor current_action = current_action_value.get_object() as GActionDescriptor;
				
				if (current_action == null) {
					select_explicit_action_members(tree_model, tree_selection, explicit_action, tree_iter);
					continue;
				}
				
				if (explicit_action.identity.contains(current_action.identity)) {
					tree_selection.select_iter(tree_iter);
				}
				
				select_explicit_action_members(tree_model, tree_selection, explicit_action, tree_iter);
			} while (tree_model.iter_next(ref tree_iter));
		}
	 }
 }
