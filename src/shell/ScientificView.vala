namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/scientific_view.ui")]
    public class ScientificView : Gtk.Grid {
        [GtkChild]
        private unowned Display display;

        private bool _collapsed;
        public bool collapsed {
            get {
                return _collapsed;
            }
            set {
                _collapsed = value;
                sci_nav_split_view.collapsed = value;
            }
        }

        [GtkChild]
        private unowned Adw.NavigationSplitView sci_nav_split_view;
    }
}