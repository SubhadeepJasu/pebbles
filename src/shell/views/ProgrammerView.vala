namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/programmer_view.ui")]
    public class ProgrammerView : View {
        private bool _collapsed;
        public bool collapsed {
            get {
                return _collapsed;
            }

            set construct {
                _collapsed = value;
            }
        }

        [GtkChild]
        private unowned ProgrammerDisplay display;

        [GtkChild]
        private unowned Gtk.Stack programmer_stack;
        [GtkChild]
        private unowned Adw.NavigationSplitView prog_nav_split_view;
        [GtkChild]
        private unowned BitGrid bit_grid;
        [GtkChild]
        private unowned Gtk.ToggleButton hex_toggle;
        [GtkChild]
        private unowned Gtk.ToggleButton dec_toggle;
        [GtkChild]
        private unowned Gtk.ToggleButton oct_toggle;
        [GtkChild]
        private unowned Gtk.ToggleButton bin_toggle;

        // Buttons
        [GtkChild]
        private unowned Gtk.ToggleButton shift_button;
        [GtkChild]
        private unowned Pebbles.Button lsh_rsh_button;
        [GtkChild]
        private unowned Pebbles.Button not_button;
        [GtkChild]
        private unowned Pebbles.Button or_button;
        [GtkChild]
        private unowned Pebbles.Button or_button_p;
        [GtkChild]
        private unowned Pebbles.Button and_button;
        [GtkChild]
        private unowned Pebbles.Button and_button_p;
        [GtkChild]
        private unowned Pebbles.Button xor_button;
        [GtkChild]
        private unowned Pebbles.Button xor_button_p;

        // Numerical keypad buttons
        [GtkChild]
        private unowned Gtk.Button one_button;
        [GtkChild]
        private unowned Gtk.Button two_button;
        [GtkChild]
        private unowned Gtk.Button three_button;
        [GtkChild]
        private unowned Gtk.Button four_button;
        [GtkChild]
        private unowned Gtk.Button five_button;
        [GtkChild]
        private unowned Gtk.Button six_button;
        [GtkChild]
        private unowned Gtk.Button seven_button;
        [GtkChild]
        private unowned Gtk.Button eight_button;
        [GtkChild]
        private unowned Gtk.Button nine_button;
        [GtkChild]
        private unowned Gtk.Button zero_button;
        [GtkChild]
        private unowned Gtk.Button paren_start_button;
        [GtkChild]
        private unowned Gtk.Button paren_end_button;

        // Hexadecimal keypad buttons
        [GtkChild]
        private unowned Gtk.Button hex_a_button;
        [GtkChild]
        private unowned Gtk.Button hex_b_button;
        [GtkChild]
        private unowned Gtk.Button hex_c_button;
        [GtkChild]
        private unowned Gtk.Button hex_d_button;
        [GtkChild]
        private unowned Gtk.Button hex_e_button;
        [GtkChild]
        private unowned Gtk.Button hex_f_button;

        private Pebbles.Settings settings;

        public signal void on_evaluate (
            string input,
            NumberSystem number_system,
            GlobalWordLength wrd_length,
            int memory_op = 0
        );
        public signal string on_memory_recall (bool global);
        public signal void on_memory_clear (bool global);

        construct {
            settings = Pebbles.Settings.get_default ();

            set_number_system (settings.number_system);

            settings.changed["number-system"].connect ((key) => {
                set_number_system (settings.number_system);
            });

            display.on_input.connect ((text) => {
                on_evaluate (
                    text,
                    settings.number_system,
                    settings.global_word_length,
                    0
                );
            });
        }

        public void show_result (string result) {
            display.show_result (result);
        }

        public void show_history (HistoryModel[] history) {
            display.show_history (history);
        }

        private void set_number_system (NumberSystem number_system) {
            switch (number_system) {
                case HEXADECIMAL:
                    hex_toggle.active = true;
                    set_keypad_mode (0);
                    break;
                case DECIMAL:
                    dec_toggle.active = true;
                    set_keypad_mode (1);
                    break;
                case OCTAL:
                    oct_toggle.active = true;
                    set_keypad_mode (2);
                    break;
                case BINARY:
                    bin_toggle.active = true;
                    set_keypad_mode (3);
                    break;
            }
        }

        // Updated set_keypad_mode to use hex keypad button references
        private void set_keypad_mode (int mode) {
            seven_button.set_sensitive (true);
            eight_button.set_sensitive (true);
            nine_button.set_sensitive (true);
            hex_a_button.set_sensitive (true);
            hex_d_button.set_sensitive (true);
            four_button.set_sensitive (true);
            five_button.set_sensitive (true);
            six_button.set_sensitive (true);
            hex_b_button.set_sensitive (true);
            hex_e_button.set_sensitive (true);
            two_button.set_sensitive (true);
            three_button.set_sensitive (true);
            hex_c_button.set_sensitive (true);
            hex_f_button.set_sensitive (true);

            if (mode == 0)
                return;

            hex_a_button.set_sensitive (false);
            hex_d_button.set_sensitive (false);
            hex_b_button.set_sensitive (false);
            hex_e_button.set_sensitive (false);
            hex_c_button.set_sensitive (false);
            hex_f_button.set_sensitive (false);

            if (mode == 1)
                return;

            eight_button.set_sensitive (false);
            nine_button.set_sensitive (false);

            if (mode == 2)
                return;

            seven_button.set_sensitive (false);
            eight_button.set_sensitive (false);
            nine_button.set_sensitive (false);
            four_button.set_sensitive (false);
            five_button.set_sensitive (false);
            six_button.set_sensitive (false);
            two_button.set_sensitive (false);
            three_button.set_sensitive (false);
        }

        [GtkCallback]
        protected void on_expand_fx () {
            prog_nav_split_view.show_content= true;
        }

        [GtkCallback]
        protected void on_collapse_fx () {
            prog_nav_split_view.show_content = false;
        }

        [GtkCallback]
        protected void on_click_button (Gtk.Button btn) {
            display.write (btn.name);
        }

        [GtkCallback]
        protected void on_click_function (Gtk.Button btn) {
            display.write (shift_button.active ? btn.name.up () : btn.name);
        }

        [GtkCallback]
        public void on_click_eval () {
            display.input ();
        }

        public void open_bit_grid () {
            programmer_stack.set_visible_child (bit_grid);
        }

        [GtkCallback]
        public void on_hide_bit_grid () {
            programmer_stack.set_visible_child (prog_nav_split_view);

            var window = (MainWindow) get_ancestor (typeof (MainWindow));
            if (window.bit_grid_toggle.active) {
                window.bit_grid_toggle.active = false;
            }
        }

        [GtkCallback]
        protected void on_number_system_toggle (Gtk.ToggleButton button) {
            if (button.active) {
                switch (button.name) {
                    case "hex-toggle":
                        settings.number_system = HEXADECIMAL;
                        break;
                    case "dec-toggle":
                        settings.number_system = DECIMAL;
                        break;
                    case "oct-toggle":
                        settings.number_system = OCTAL;
                        break;
                    case "bin-toggle":
                        settings.number_system = BINARY;
                        break;
                }
            }
        }

        [GtkCallback]
        protected void on_shift () {
            not_button.label_text = shift_button.active ? "Mod" : "Not";
            not_button.tooltip_desc = shift_button.active
                                    ? _("Modulus")
                                    : _("Bitwise Inverter (TRUE for input being FALSE and vice versa)");
            and_button.label_text = shift_button.active ? "Nand" : "And";
            and_button.tooltip_desc = shift_button.active
                                    ? _("Bitwise NOT-of-AND (FALSE only for all inputs being TRUE)")
                                    : _("Bitwise AND (TRUE for all inputs being TRUE)");
            and_button_p.label_text = and_button.label_text;
            and_button_p.tooltip_desc = and_button.tooltip_desc;

            or_button.label_text = shift_button.active ? "Nor" : "Or";
            or_button.tooltip_desc = shift_button.active
                                    ? _("Bitwise NOT-of-OR (TRUE only for all inputs being FALSE)")
                                    : _("Bitwise OR (TRUE for any input being TRUE)");
            or_button_p.label_text = or_button.label_text;
            or_button_p.tooltip_desc = or_button.tooltip_desc;

            xor_button.label_text = shift_button.active ? "Xnor" : "Xor";
            xor_button.tooltip_desc = shift_button.active
                                    ? _("Logical NOT-of-XOR (TRUE only for all inputs being same)")
                                    : _("Logical Exclusive-OR (TRUE for exactly one input being TRUE)");
            xor_button_p.label_text = xor_button.label_text;
            xor_button_p.tooltip_desc = xor_button.tooltip_desc;

            lsh_rsh_button.label_text = shift_button.active ? "Rsh" : "Lsh";
            lsh_rsh_button.tooltip_desc = shift_button.active ? _("Right Shift") : _("Left Shift");
        }

        [GtkCallback]
        protected void on_all_clear () {
            display.all_clear ();
        }

        [GtkCallback]
        public void on_backspace () {
            display.backspace ();
        }

        [GtkCallback]
        protected void set_bits_from_grid (Gtk.Widget _, bool[] arr) {
            display.set_last_token_from_bit_grid (arr);
        }

        [GtkCallback]
        protected void last_bits_changed (Gtk.Widget _, bool[] arr) {
            bit_grid.set_bits (arr);
        }

        [GtkCallback]
        protected void on_click_add_button () {
            display.write ("+");
        }

        [GtkCallback]
        protected void on_click_sub_button () {
            display.write ("-");
        }

        [GtkCallback]
        protected void on_click_mul_button () {
            display.write ("*");
        }

        [GtkCallback]
        protected void on_click_div_button () {
            display.write ("/");
        }

        [GtkCallback]
        public void on_click_memory_add () {
            on_evaluate (
                display.main_entry.text,
                settings.number_system,
                settings.global_word_length,
                shift_button.active ? MemAppendOp.ADD_GLOBAL : MemAppendOp.ADD
            );
        }

        [GtkCallback]
        public void on_click_memory_subtract () {
            on_evaluate (
                display.main_entry.text,
                settings.number_system,
                settings.global_word_length,
                shift_button.active ? MemAppendOp.SUBTRACT_GLOBAL : MemAppendOp.SUBTRACT
            );
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

        public void send_shift_modifier (bool shifted) {
            shift_button.active = shifted;
            on_shift ();
        }

        public override void focus_main () {
            display.focus_entry ();
        }
    }
}
