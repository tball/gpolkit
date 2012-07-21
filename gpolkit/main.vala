using GPolkit;
using GPolkit.Gui;

namespace GPolkit {
	static int main (string[] args) {
		Program program = new Program();
		program.setup_ui(args);
		program.run();

		return 0;
	}
}
