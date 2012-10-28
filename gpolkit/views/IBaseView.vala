using GPolkit.Models;

namespace GPolkit.Views {
	public interface IBaseView : GLib.Object {
		public abstract void connect_model(BaseModel baseModel);
	} 
}
