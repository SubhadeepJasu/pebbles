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
        [GtkChild]
        private unowned StyledButton expo_power_button;
        [GtkChild]
        private unowned StyledButton sin_button;
        [GtkChild]
        private unowned StyledButton sinh_button;
        [GtkChild]
        private unowned StyledButton log_cont_base_button;
        [GtkChild]
        private unowned StyledButton cos_button;
        [GtkChild]
        private unowned StyledButton cosh_button;
        [GtkChild]
        private unowned StyledButton log_mod_button;
        [GtkChild]
        private unowned StyledButton tan_button;
        [GtkChild]
        private unowned StyledButton tanh_button;
        [GtkChild]
        private unowned StyledButton perm_comb_button;
        [GtkChild]
        private unowned StyledButton fact_button;
        [GtkChild]
        private unowned StyledButton constant_button;

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
                expo_power_button.label_text = "e<sup>x</sup>";
                expo_power_button.tooltip_desc = _("e raised to the power x");
                sin_button.label_text = "sin<sup>-1</sup>";
                sin_button.tooltip_desc = _("Inverse Sine");
                cos_button.label_text = "cos<sup>-1</sup>";
                cos_button.tooltip_desc = _("Inverse Cosine");
                tan_button.label_text = "tan<sup>-1</sup>";
                tan_button.tooltip_desc = _("Inverse Tangent");
                sinh_button.label_text = "sinh<sup>-1</sup>";
                sinh_button.tooltip_desc = _("Inverse Hyperbolic Sine");
                cosh_button.label_text = "cosh<sup>-1</sup>";
                cosh_button.tooltip_desc = _("Inverse Hyperbolic Cosine");
                tanh_button.label_text = "tanh<sup>-1</sup>";
                tanh_button.tooltip_desc = _("Inverse Hyperbolic Tangent");
                log_mod_button.label_text = "log<sub>x</sub>y";
                log_mod_button.tooltip_desc = _("Log Base x");
                log_cont_base_button.label_text = "ln x";
                log_cont_base_button.tooltip_desc = _("Natural Logarithm");
                perm_comb_button.label_text = "<sup>n</sup>C<sub>r</sub>";
                perm_comb_button.tooltip_desc = _("Combinations");
            } else {
                pow_root_button.label_text = "x<sup>y</sup>";
                pow_root_button.tooltip_desc = _("x raised to the power y");
                expo_power_button.label_text = "10<sup>x</sup>";
                expo_power_button.tooltip_desc = _("10 raised to the power x");
                sin_button.label_text = "sin";
                sin_button.tooltip_desc = _("Sine");
                cos_button.label_text = "cos";
                cos_button.tooltip_desc = _("Cosine");
                tan_button.label_text = "tan";
                tan_button.tooltip_desc = _("Tangent");
                sinh_button.label_text = "sinh";
                sinh_button.tooltip_desc = _("Hyperbolic Sine");
                cosh_button.label_text = "cosh";
                cosh_button.tooltip_desc = _("Hyperbolic Cosine");
                tanh_button.label_text = "tanh";
                tanh_button.tooltip_desc = _("Hyperbolic Tangent");
                log_mod_button.label_text = "|Mod|";
                log_mod_button.tooltip_desc = _("Modulus");
                log_cont_base_button.label_text = "log x";
                log_cont_base_button.tooltip_desc = _("Log Base 10");
                perm_comb_button.label_text = "<sup>n</sup>P<sub>r</sub>";
                perm_comb_button.tooltip_desc = _("Permutations");
            }
        }

        public void evaluate (string text) {
            on_evaluate (text);
        }

        public void show_result (string result) {
            display.show_result (result);
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

        public void send_shift_modifier (bool shifted) {
            shift_button.active = shifted;
            on_shift ();
        }

        [GtkCallback]
        public void on_pow_root_button () {
            display.write (shift_button.active ? "Q" : "q");
        }

        [GtkCallback]
        public void on_expo_power_button () {
            display.write (shift_button.active ? "Z" : "z");
        }

        [GtkCallback]
        public void on_sin_button () {
            display.write (shift_button.active ? "S" : "s");
        }

        [GtkCallback]
        public void on_sinh_button () {
            display.write (shift_button.active ? "H" : "h");
        }

        [GtkCallback]
        public void on_log_cont_base_button () {
            display.write (shift_button.active ? "L" : "l");
        }

        [GtkCallback]
        public void on_cos_button () {
            display.write (shift_button.active ? "C" : "c");
        }

        [GtkCallback]
        public void on_cosh_button () {
            display.write (shift_button.active ? "O" : "o");
        }

        [GtkCallback]
        public void on_log_mod_button () {
            display.write (shift_button.active ? "M" : "m");
        }

        [GtkCallback]
        public void on_tan_button () {
            display.write (shift_button.active ? "T" : "t");
        }

        [GtkCallback]
        public void on_tanh_button () {
            display.write (shift_button.active ? "A" : "a");
        }

        [GtkCallback]
        public void on_perm_comb_button () {
            display.write (shift_button.active ? "P" : "p");
        }

        [GtkCallback]
        public void on_fact_button () {
            display.write ("F");
        }
    }
}