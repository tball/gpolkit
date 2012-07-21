using GPolkit.Gui;

namespace GPolkit {
	class Program : Object {
		private MainWindow main_window_model_view = null;
		private Gtk.Window main_window_view = null;

		public Program( ) {
			/* Object( application_id: "gpolkit",
			        flags: ApplicationFlags.FLAGS_NONE );*/

		}

		public void setup_ui(string[] args) {
			Gtk.init (ref args);
			main_window_model_view = new MainWindow();
			main_window_view = main_window_model_view.view;
			main_window_view.destroy.connect(Gtk.main_quit);

			main_window_view.show_all( );

		}

		public void run() {
			Gtk.main();
		}
	}
}
