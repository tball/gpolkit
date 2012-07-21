using Gtk;
using Gee;
using GPolkit.Common;

namespace GPolkit.Gui
{
	public class MainWindow : Object {
		private TreeStoreProxy tree_store_proxy = null;
		private TreeView tree_view = null;
		private GPolkitHelper gpolkit_helper = null;
		private ComboBox combo_box_allow_any = null;
		private ComboBox combo_box_allow_active = null;
		private ComboBox combo_box_allow_inactive = null;
		private Label label_action_description = null;
		private Label label_action_vendor = null;
		private Label label_action_vendor_url = null;
		
		

		public GActionDescriptor currently_selected_action { get; set; default = null;}
		public Window view { get; set; default = null;}
		public ArrayList<GActionDescriptor> actions {get; set; default = null;}
		public string test { get; set; default = null;}
		

		[CCode(instance_pos=-1)]
		public void on_button_fetch_policies_clicked (Button source) {
			tree_store_proxy.update_policies(actions);
		}

		[CCode(instance_pos=-1)]
		public void treeview_selection_changed(Object sender)//TreePath path, TreeViewColumn col)
		{
			TreeIter selected_iter;
			TreeModel model;
			
			tree_view.get_selection().get_selected(out model, out selected_iter);

			if (selected_iter.user_data == null || model == null) {
				return;
			}

			Value action_value;
			model.get_value(selected_iter, TreeStoreProxy.ColumnTypes.ACTION_REF, out action_value);
			
			if(!action_value.holds(typeof(GActionDescriptor))) {
				// TODO: Prober warning
				return;
			}
			currently_selected_action = (GActionDescriptor)action_value.get_object();
		}
		
		private void update_action_widget(GActionDescriptor? action)
		{
			label_action_description.set_sensitive(action != null);
			label_action_vendor.set_sensitive(action != null);
			label_action_vendor_url.set_sensitive(action != null);
			combo_box_allow_any.set_sensitive(action != null);
			combo_box_allow_active.set_sensitive(action != null);
		    combo_box_allow_inactive.set_sensitive(action != null);
			
			if (action == null) {
				return;
			}
		
			label_action_description.set_text(action.description);
			label_action_vendor.set_text(action.vendor);
			label_action_vendor_url.set_text(action.vendor_url);
			
			Polkit.ImplicitAuthorization allow_any_impl;
			Polkit.ImplicitAuthorization.from_string(action.allow_any, out allow_any_impl);
			combo_box_allow_any.set_active((int)allow_any_impl);
			
			Polkit.ImplicitAuthorization allow_active_impl;
			Polkit.ImplicitAuthorization.from_string(action.allow_active, out allow_active_impl);
			combo_box_allow_active.set_active((int)allow_active_impl);
			
			Polkit.ImplicitAuthorization allow_inactive_impl;
			Polkit.ImplicitAuthorization.from_string(action.allow_inactive, out allow_inactive_impl);
			combo_box_allow_inactive.set_active((int)allow_inactive_impl);
		}

		private Window build_ui() {
			var builder = new Builder();
			try {
				builder.add_from_file(Ressources.DATA_DIR + """/MainWindow.ui""");
			}
			catch(Error e) {
				stdout.printf("Error compiling the MainWindow.ui: %s\n", e.message);
			}

			var window = builder.get_object("mainWindow") as Window;


			// Fetch fields from ui
			tree_view = builder.get_object("treeviewPolicies") as TreeView;
			combo_box_allow_any = builder.get_object("combobox_allow_any") as ComboBox;
			combo_box_allow_active = builder.get_object("combobox_allow_active") as ComboBox;
			combo_box_allow_inactive = builder.get_object("combobox_allow_inactive") as ComboBox;
			label_action_description = builder.get_object("label_action_description") as Label;
			label_action_vendor = builder.get_object("label_action_vendor") as Label;
			label_action_vendor_url = builder.get_object("label_action_vendor_url") as Label;

			// Connect signals
			builder.connect_signals(this);

			return window;
		}

		private void init() {
			tree_store_proxy = new TreeStoreProxy();

			// Set our treeView model
			tree_view.set_model(tree_store_proxy);

			// Init helper
			try {
				gpolkit_helper = Bus.get_proxy_sync (BusType.SESSION, "org.gnome.gpolkit.helper",
													"/org/gnome/gpolkit/helper");

			} catch (IOError e) {
				stderr.printf ("%s\n", e.message);
			}


			// Init bindings
			this.notify["actions"].connect(tree_store_proxy.policies_changed);
			this.notify["currently-selected-action"].connect((sender, param_spec) => {
				update_action_widget(currently_selected_action);
			});
			
			// Fetch policies
			HashTable<string,Variant>[] hash_tables = gpolkit_helper.get_implicit_policies ();
			actions = GActionDescriptor.de_serialize_array(hash_tables);
		}

		public MainWindow() {
			this.notify.connect((sender, property) => {
					stdout.printf ("Property '%s' changed\n", property.name);
				});
		
			// Load ui file
			this.view = build_ui();

			// Init
			init();
		}
	}
}