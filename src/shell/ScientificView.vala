namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/scientific_view.ui")]
    public class ScientificView : Gtk.Grid {
        [GtkChild]
        private unowned Display display;

        // Buttons
        [GtkChild]
        private unowned StyledButton all_clear_button;
        [GtkChild]
        private unowned Gtk.Button del_button;

        public bool collapsed { get; set; }

        [GtkChild]
        private unowned Adw.NavigationSplitView sci_nav_split_view;

        construct {
            del_button.remove_css_class ("image-button");
        }
    }
}