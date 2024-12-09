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
        private unowned StyledButton zero_button;
        [GtkChild]
        private unowned StyledButton one_button;
        [GtkChild]
        private unowned StyledButton two_button;
        [GtkChild]
        private unowned StyledButton three_button;
        [GtkChild]
        private unowned StyledButton four_button;
        [GtkChild]
        private unowned StyledButton five_button;
        [GtkChild]
        private unowned StyledButton six_button;
        [GtkChild]
        private unowned StyledButton seven_button;
        [GtkChild]
        private unowned StyledButton eight_button;
        [GtkChild]
        private unowned StyledButton nine_button;
        [GtkChild]
        private unowned StyledButton point_button;
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

        public void send_key_down (uint keyval) {
            switch (keyval) {
                case Gdk.Key.@0:
                    zero_button.show_as_pressed ();
                    break;
                case Gdk.Key.@1:
                    one_button.show_as_pressed ();
                    break;
                case Gdk.Key.@2:
                    two_button.show_as_pressed ();
                    break;
                case Gdk.Key.@3:
                    three_button.show_as_pressed ();
                    break;
                case Gdk.Key.@4:
                    four_button.show_as_pressed ();
                    break;
                case Gdk.Key.@5:
                    five_button.show_as_pressed ();
                    break;
                case Gdk.Key.@6:
                    six_button.show_as_pressed ();
                    break;
                case Gdk.Key.@7:
                    seven_button.show_as_pressed ();
                    break;
                case Gdk.Key.@8:
                    eight_button.show_as_pressed ();
                    break;
                case Gdk.Key.@9:
                    nine_button.show_as_pressed ();
                    break;
                case Gdk.Key.period:
                    point_button.show_as_pressed ();
                    break;
                default:
                break;
            }
        }

        public void send_key_up (uint keyval) {
            switch (keyval) {
                case Gdk.Key.@0:
                    zero_button.show_as_pressed (false);
                    break;
                case Gdk.Key.@1:
                    one_button.show_as_pressed (false);
                    break;
                case Gdk.Key.@2:
                    two_button.show_as_pressed (false);
                    break;
                case Gdk.Key.@3:
                    three_button.show_as_pressed (false);
                    break;
                case Gdk.Key.@4:
                    four_button.show_as_pressed (false);
                    break;
                case Gdk.Key.@5:
                    five_button.show_as_pressed (false);
                    break;
                case Gdk.Key.@6:
                    six_button.show_as_pressed (false);
                    break;
                case Gdk.Key.@7:
                    seven_button.show_as_pressed (false);
                    break;
                case Gdk.Key.@8:
                    eight_button.show_as_pressed (false);
                    break;
                case Gdk.Key.@9:
                    nine_button.show_as_pressed (false);
                    break;
                case Gdk.Key.period:
                case Gdk.Key.comma:
                    point_button.show_as_pressed (false);
                    break;
                default:
                break;
            }
        }
    }
}