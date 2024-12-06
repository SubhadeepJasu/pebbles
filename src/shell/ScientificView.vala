namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/scientific_view.ui")]
    public class ScientificView : Gtk.Grid {
        [GtkChild]
        private unowned ScientificDisplay display;

        // Buttons
        [GtkChild]
        private unowned StyledButton all_clear_button;
        [GtkChild]
        private unowned Gtk.Button del_button;
        [GtkChild]
        private unowned Gtk.ToggleButton shift_button;
        [GtkChild]
        private unowned StyledButton pow_root_button;

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

        public signal void on_evaluate (string input);

        construct {
            del_button.remove_css_class ("image-button");
            display.on_input.connect (evaluate);
        }

        [GtkCallback]
        protected void on_expand_fx () {
            sci_nav_split_view.show_content= true;
        }

        [GtkCallback]
        protected void on_collapse_fx () {
            sci_nav_split_view.show_content = false;
        }

        [GtkCallback]
        protected void on_shift () {
            if (shift_button.active) {
                pow_root_button.label_text = "<sup>n</sup>√";
                pow_root_button.tooltip_desc = _("Square root over number");
                pow_root_button.accel_markup = "Q";
            } else {
                pow_root_button.label_text = "x<sup>y</sup>";
                pow_root_button.tooltip_desc = _("x raised to the power y");
                pow_root_button.accel_markup = "Z";
            }
        }            

        public void evaluate (string text) {
            on_evaluate (text);
        }
    }
}