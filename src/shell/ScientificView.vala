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
        protected string constant_label { get; private set; default = "C"; }
        protected string constant_desc { get; private set; default = ""; }

        [GtkChild]
        private unowned Adw.NavigationSplitView sci_nav_split_view;

        public signal void on_evaluate (string input, int memory_op = 0);
        public signal string on_memory_recall (bool global);
        public signal void on_memory_clear (bool global);

        construct {
            del_button.remove_css_class ("image-button");
            display.on_input.connect (evaluate);
            load_constant_button ();
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
            pow_root_button.label_text = shift_button.active ? "<sup>n</sup>√" : "x<sup>y</sup>";
            pow_root_button.tooltip_desc = shift_button.active
            ? _("Square root over number") : _("x raised to the power y");
            expo_power_button.label_text = shift_button.active ? "e<sup>x</sup>" : "10<sup>x</sup>";
            expo_power_button.tooltip_desc = shift_button.active
            ? _("e raised to the power x") : _("10 raised to the power x");
            sin_button.label_text = shift_button.active ? "sin<sup>-1</sup>" : "sin";
            sin_button.tooltip_desc = shift_button.active ? _("Inverse Sine") : _("Sine");
            cos_button.label_text = shift_button.active ? "cos<sup>-1</sup>" : "cos";
            cos_button.tooltip_desc = shift_button.active ? _("Inverse Cosine") : _("Cosine");
            tan_button.label_text = shift_button.active ? "tan<sup>-1</sup>" : "tan";
            tan_button.tooltip_desc = shift_button.active ? _("Inverse Tangent") : _("Tangent");
            sinh_button.label_text = shift_button.active ? "sinh<sup>-1</sup>" : "sinh";
            sinh_button.tooltip_desc = shift_button.active ? _("Inverse Hyperbolic Sine") : _("Hyperbolic Sine");
            cosh_button.label_text = shift_button.active ? "cosh<sup>-1</sup>" : "cosh";
            cosh_button.tooltip_desc = shift_button.active ? _("Inverse Hyperbolic Cosine") : _("Hyperbolic Cosine");
            tanh_button.label_text = shift_button.active ? "tanh<sup>-1</sup>" : "tan";
            tanh_button.tooltip_desc = shift_button.active ? _("Inverse Hyperbolic Tangent") : _("Hyperbolic Tangent");
            log_mod_button.label_text = shift_button.active ? "log<sub>x</sub>y" : "|Mod|";
            log_mod_button.tooltip_desc = shift_button.active ? _("Log Base x") : _("Modulus");
            log_cont_base_button.label_text = shift_button.active ? "ln x" : "log x";
            log_cont_base_button.tooltip_desc = shift_button.active ? _("Natural Logarithm") : _("Log Base 10");
            perm_comb_button.label_text = shift_button.active
            ? "<sup>n</sup>C<sub>r</sub>" : "<sup>n</sup>P<sub>r</sub>";
            perm_comb_button.tooltip_desc = shift_button.active ? _("Combinations") : _("Permutations");
            memory_plus_button.label_text = shift_button.active ? "GM+" : "M+";
            memory_plus_button.tooltip_desc = shift_button.active
            ? _("Add it to the value in Global Memory") : _("Add it to the value in Memory");
            memory_minus_button.label_text = shift_button.active ? "GM−" : "M−";
            memory_minus_button.tooltip_desc = shift_button.active
            ? _("Subtract it from the value in Global Memory")
            : _("Subtract it from the value in Memory");
            memory_recall_button.label_text = shift_button.active ? "GMR" : "MR";
            memory_recall_button.tooltip_desc = shift_button.active
            ? _("Recall value from Global Memory") : _("Recall value from Memory");
            memory_clear_button.label_text = shift_button.active ? "GMC" : "MC";
            memory_clear_button.tooltip_desc = shift_button.active ? _("Global Memory Clear") : _("Memory Clear");
            last_answer_button.label_text = shift_button.active ? "GAns" : "Ans";
            last_answer_button.tooltip_desc = shift_button.active
            ? _("Insert global last answer") : _("Insert last answer");
            last_answer_button_p.label_text = shift_button.active ? "GAns" : "Ans";
            last_answer_button_p.tooltip_desc = shift_button.active
            ? _("Insert global last answer") : _("Insert last answer");

            load_constant_button ();
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

        private void load_constant_button () {
            var settings = Pebbles.Settings.get_default ();

            var key = shift_button.active ? settings.constant_key_value2 : settings.constant_key_value1;
            switch (key) {
                case ARCHIMEDES:
                    constant_label = "π";
                    constant_desc = _("Archimedes' constant (pi)");
                    break;
                case IMAGINARY:
                    constant_label = "j";
                    constant_desc = _("Imaginary Number (√-1)");
                    break;
                case GOLDEN_RATIO:
                    constant_label = "\xCF\x86";
                    constant_desc = _("Golden ratio (phi)");
                    break;
                case EULER_MASCH:
                    constant_label = "\xF0\x9D\x9B\xBE";
                    constant_desc = _("Euler–Mascheroni constant (gamma)");
                    break;
                case CONWAY:
                    constant_label = "\xCE\xBB";
                    constant_desc = _("Conway's constant (lambda)");
                    break;
                case KHINCHIN:
                    constant_label = "K";
                    constant_desc = _("Khinchin's constant");
                    break;
                case FEIGEN_ALPHA:
                    constant_label = "\xCE\xB1";
                    constant_desc = _("The Feigenbaum constant alpha");
                    break;
                case FEIGEN_DELTA:
                    constant_label = "\xCE\xB4";
                    constant_desc = _("The Feigenbaum constant delta");
                    break;
                case APERY:
                    constant_label = "\xF0\x9D\x9B\x87(3)";
                    constant_desc = _("Apery's constant");
                    break;
                default:
                    constant_label = "e";
                    constant_desc = _("Euler's constant (exponential)");
                    break;
            }
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
        protected void on_click_add_button () {
            display.write ("+");
        }

        [GtkCallback]
        protected void on_click_sub_button () {
            display.write ("−");
        }

        [GtkCallback]
        protected void on_click_mul_button () {
            display.write ("×");
        }

        [GtkCallback]
        protected void on_click_div_button () {
            display.write ("÷");
        }

        [GtkCallback]
        protected void on_click_function (Gtk.Button btn) {
            display.write (shift_button.active ? btn.name.up () : btn.name);
        }

        [GtkCallback]
        protected void on_click_fraction_point () {
            display.write (_("."));
        }

        [GtkCallback]
        protected void on_click_constant (Gtk.Button button) {
            display.write (((StyledButton) button).label_text);
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
