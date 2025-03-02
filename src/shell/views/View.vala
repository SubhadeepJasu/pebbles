namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/view.ui")]
    public abstract class View : Gtk.Grid {
        public string context { get; protected set; }
    }
}
