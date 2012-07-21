
namespace GPolkit.Common {
	[DBus (name = "org.gnome.gpolkit.helper")]
	public interface GPolkitHelper : Object {
		public abstract HashTable<string,Variant>[] get_implicit_policies () throws IOError;
	}
}
