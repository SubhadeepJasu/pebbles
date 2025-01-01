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
        [GtkChild]
        private unowned StyledButton last_answer_button_p;
        [GtkChild]
        private unowned StyledButton last_answer_button;
        [GtkChild]
        private unowned StyledButton memory_plus_button;
        [GtkChild]
        private unowned StyledButton memory_minus_button;
        [GtkChild]
        private unowned StyledButton memory_recall_button;
        [GtkChild]
        private unowned StyledButton memory_clear_button;

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

        public signal void on_evaluate (string input, int memory_op = 0);
        public signal string on_memory_recall (bool global);
        public signal void on_memory_clear (bool global);

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
                memory_plus_button.label_text = "GM+";
                memory_plus_button.tooltip_desc = _("Add it to the value in Global Memory");
                memory_minus_button.label_text = "GM−";
                memory_minus_button.tooltip_desc = _("Subtract it from the value in Global Memory");
                memory_recall_button.label_text = "GMR";
                memory_recall_button.tooltip_desc = _("Recall value from Global Memory");
                memory_clear_button.label_text = "GMC";
                memory_clear_button.tooltip_desc = _("Global Memory Clear");
                last_answer_button.label_text = "GAns";
                last_answer_button.tooltip_desc = _("Insert global last answer");
                last_answer_button_p.label_text = "GAns";
                last_answer_button_p.tooltip_desc = _("Insert global last answer");
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
                memory_plus_button.label_text = "M+";
                memory_plus_button.tooltip_desc = _("Add it to the value in Memory");
                memory_minus_button.label_text = "M−";
                memory_minus_button.tooltip_desc = _("Subtract it from the value in Memory");
                memory_recall_button.label_text = "MR";
                memory_recall_button.tooltip_desc = _("Recall value from Memory");
                memory_clear_button.label_text = "MC";
                memory_clear_button.tooltip_desc = _("Memory Clear");
                last_answer_button.label_text = "Ans";
                last_answer_button.tooltip_desc = _("Insert last answer");
                last_answer_button_p.label_text = "Ans";
                last_answer_button_p.tooltip_desc = _("Insert last answer");
            }
        }

        public void evaluate (string text) {
            on_evaluate (text);
        }

        public void show_result (string result) {
            display.show_result (result);
        }

        public void set_memory_present (bool present) {
            display.set_memory_present (present);
        }

        public void set_global_memory_present (bool present) {
            display.set_global_memory_present (present);
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
                case Gdk.Key.Delete:
                case Gdk.Key.KP_Delete:
                    all_clear_button.show_as_pressed ();
                    break;
                case Gdk.Key.BackSpace:
                    del_button.add_css_class ("pressed");
                    break;
                default:
                    break;
            }
        }

        public void send_key_up (uint keyval) {
            print ("%u\n", keyval);
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
                case Gdk.Key.Delete:
                case Gdk.Key.KP_Delete:
                    all_clear_button.show_as_pressed (false);
                    on_all_clear ();
                    break;
                case Gdk.Key.BackSpace:
                    del_button.remove_css_class ("pressed");
                    on_backspace ();
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
        public void on_all_clear () {
            display.all_clear ();
        }

        [GtkCallback]
        public void on_backspace () {
            display.backspace ();
        }

        [GtkCallback]
        public void on_click_button (Gtk.Button btn) {
            display.write (btn.name);
        }

        [GtkCallback]
        public void on_click_add_button () {
            display.write ("+");
        }

        [GtkCallback]
        public void on_click_sub_button () {
            display.write ("−");
        }

        [GtkCallback]
        public void on_click_mul_button () {
            display.write ("×");
        }

        [GtkCallback]
        public void on_click_div_button () {
            display.write ("÷");
        }

        [GtkCallback]
        public void on_click_function (Gtk.Button btn) {
            display.write (shift_button.active ? btn.name.up () : btn.name);
        }

        [GtkCallback]
        public void on_click_fraction_point () {
            display.write (".");
        }

        [GtkCallback]
        public void on_click_last_ans () {
            display.write (shift_button.active ? "Gans" : "ans");
        }

        [GtkCallback]
        public void on_click_memory_add () {
            on_evaluate (display.main_entry.text, shift_button.active ? 2 : 1); // 1: Memory, 2: Global Memory
        }

        [GtkCallback]
        public void on_click_memory_subtract () {
            on_evaluate (display.main_entry.text, shift_button.active ? -2 : -1); // -1: Memory, -2: Global Memory
        }

        [GtkCallback]
        public void on_click_memory_recall () {
            var text = on_memory_recall (shift_button.active);
            display.write (text);
        }

        [GtkCallback]
        public void on_click_memory_clear () {
            on_memory_clear (shift_button.active);
        }

        [GtkCallback]
        public void on_click_eval () {
            display.input ();
        }
    }
}
