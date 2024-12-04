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

        private bool _collapsed;
        public bool collapsed {
            get {
                return _collapsed;
            }

            set construct {
                _collapsed = value;
                show_hide_fx_btn = !value;
            }
        }

        protected bool show_hide_fx_btn { get; set; }

        [GtkChild]
        private unowned Adw.NavigationSplitView sci_nav_split_view;

        construct {
            del_button.remove_css_class ("image-button");
        }

        [GtkCallback]
        protected void on_expand_fx () {
            sci_nav_split_view.show_content= true;
        }

        [GtkCallback]
        protected void on_collapse_fx () {
            sci_nav_split_view.show_content = false;
        }
    }
}