namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/scientific_display.ui")]
    public class ScientificDisplay : Display {
        private Pebbles.Settings settings;
        private bool _shift_on;
        public bool shift_on {
            get {
                return _shift_on;
            } set {
                _shift_on = value;
                shift_label.opacity = value ? 1 : 0.2;
            }
        }

        [GtkChild]
        private unowned Gtk.Label deg_label;
        [GtkChild]
        private unowned Gtk.Label rad_label;
        [GtkChild]
        private unowned Gtk.Label grad_label;
        [GtkChild]
        private unowned Gtk.Label shift_label;
        [GtkChild]
        private unowned Gtk.Label memory_label;
        [GtkChild]
        private unowned Gtk.Label global_memory_label;
        [GtkChild]
        private unowned Gtk.Label main_label;
        [GtkChild]
        public unowned Gtk.Entry main_entry;
        [GtkChild]
        public unowned HistoryDisplay history_display;

        private Gtk.GestureClick right_click_gesture;

        construct {
            Idle.add (()=> {
                Timeout.add (60, ()=> {
                    if (animation_frame < animation_frames.length) {
                        main_label.label = animation_frames[animation_frame];
                        animation_frame++;
                        return true;
                    }

                    main_label.label = "0";
                    main_entry.text = "0";
                    main_entry.grab_focus_without_selecting ();
                    main_entry.set_position (1);
                    history_display.visible = true;
                    history_display.add_css_class ("animate-in");

                    return false;
                });

                return false;
            }, Priority.LOW);

            // TODO: Do token check before inserting any character
            main_entry.get_delegate ().insert_text.connect_after ((ch, length) => {
                var text = main_entry.text;
                Idle.add (() => {
                    if (text.length > 1 && text.has_prefix ("0")) {
                        main_entry.text = text.substring (1);
                        main_entry.set_position (1);
                        return Source.REMOVE;
                    }

                    if (length > 1) {
                        return Source.REMOVE;
                    }

                    Idle.add (() => {
                        if (main_entry.text_length > 1)
                        replace_inserted_character (main_entry.text, main_entry.text_length, main_entry.get_position ());
                        return Source.REMOVE;
                    });
                    return Source.REMOVE;
                });
            });

            main_entry.get_delegate ().delete_text.connect_after (() => {
                Idle.add (() => {
                    if (main_entry.text_length == 0) {
                        main_entry.text = "0";
                        main_entry.set_position ((int) main_entry.text_length);
                    }

                    return Source.REMOVE;
                });
            });

            settings = Pebbles.Settings.get_default ();
            settings.changed["global-angle-unit"].connect ((key) => {
                set_angle_unit (settings.global_angle_unit);
            });

            realize.connect_after (() => {
                var window = (MainWindow) get_ancestor (typeof (MainWindow));
                window.on_key_down.connect ((mode) => {
                    if (mode == Pebbles.Context.SCIENTIFIC && !main_entry.has_focus) {
                        main_entry.grab_focus_without_selecting ();
                    }
                });
            });

            set_angle_unit (settings.global_angle_unit);

            right_click_gesture = new Gtk.GestureClick ();
            right_click_gesture.set_button (Gdk.BUTTON_SECONDARY);
            right_click_gesture.pressed.connect (() => {

            });
        }

        public void set_angle_unit (GlobalAngleUnit unit) {
            switch (unit) {
                case DEG:
                    deg_label.opacity = 1;
                    rad_label.opacity = 0.2;
                    grad_label.opacity = 0.2;
                    break;
                case RAD:
                    deg_label.opacity = 0.2;
                    rad_label.opacity = 1;
                    grad_label.opacity = 0.2;
                    break;
                case GRAD:
                    deg_label.opacity = 0.2;
                    rad_label.opacity = 0.2;
                    grad_label.opacity = 1;
                    break;
            }
        }

        [GtkCallback]
        public void input () {
            on_input (main_entry.text);
        }

        public void show_result (string result) {
            if (result != "E") {
                add_css_class ("fade");
                Timeout.add (100, () => {
                    main_label.set_text (result);
                    remove_css_class ("fade");
                    return false;
                });
            } else {
                main_label.set_text (_("Error"));
                add_css_class ("shake");
                Timeout.add_once (400, () => {
                    remove_css_class ("shake");
                    main_entry.grab_focus_without_selecting ();
                });
            }
        }

        public void show_history (HistoryModel[] history) {
            history_display.update_list (history);
        }

        public void all_clear () {
            show_result ("0");
            main_entry.text = "0";
            main_entry.set_position (1);
        }

        public void backspace () {
            int start, end;
            main_entry.get_selection_bounds (out start, out end);

            if (start == end) {
                int pos = main_entry.get_position ();
                if (pos > 0) {
                    main_entry.delete_text (pos - 1, pos);
                    main_entry.set_position (pos - 1);
                }
            } else {
                main_entry.delete_text (start, end);
                main_entry.set_position (start);
            }
        }

        public void write (string str) {
            int position = main_entry.get_position ();
            main_entry.do_insert_text (str, str.length, ref position);
            main_entry.set_position (position);
        }

        private string[] split_utf8 (string text, uint text_length) {
            var result = new string[text_length + 1];
            var j = 0;

            var sb = new StringBuilder ();
            for (int i = 0; i <= text.length; i++) {
                if ((text[i] & 0xC0) != 0x80) { // Prevent commiting if its a continuation bit
                    result[j++] = sb.str + "";
                    sb.erase (0, sb.len);
                }

                if (text[i] != '\0') {
                    sb.append_c (text[i]);
                }
            }

            return result;
        }

        public void replace_inserted_character (string text, uint text_length, int caret_pos) {
            var symbols = split_utf8 (text, text_length);
            var current_symbol = symbols[caret_pos];
            if (current_symbol == null) {
                return;
            }
            var previous_symbol = "";
            var previous_caret_pos = caret_pos - 1;
            for (int i = caret_pos - 1; i >= 0; i--) {
                if (symbols[i] != " ") {
                    previous_symbol = symbols[i];
                    previous_caret_pos = i;
                    break;
                }
            }

            print ("%s, %s\n", previous_symbol, current_symbol);

            bool double_replaced;
            int len_gain;
            var replacement = find_replacement (current_symbol, previous_symbol, out double_replaced, out len_gain);
            symbols[caret_pos] = replacement;
            if (double_replaced) {
                symbols[previous_caret_pos] = "";
                if (previous_caret_pos > 0 && symbols[previous_caret_pos - 1] == " ") {
                    symbols[previous_caret_pos - 1] = "";
                }

                if (previous_caret_pos < text_length - 1 && symbols[previous_caret_pos + 1] == " ") {
                    symbols[previous_caret_pos + 1] = "";
                }
            }

            main_entry.text = string.joinv ("", symbols);
            if (double_replaced) {
                main_entry.set_position (caret_pos - 1);
            } else {
                main_entry.set_position (caret_pos + len_gain);
            }
        }


        public string find_replacement (string current_symbol, string previous_symbol, out bool double_replaced, out int len_gain) {
            double_replaced = false;
            switch (current_symbol) {
                case "+":
                    len_gain = 2;
                    return " + ";
                case "−":
                case "-":
                    len_gain = 2;
                    return " − ";
                case "÷":
                case "/":
                    len_gain = 2;
                    return " ÷ ";
                case "×":
                case "*":
                    len_gain = 2;
                    if (previous_symbol == "×") {
                        double_replaced = true;
                        return " ^ ";
                    }

                    return " × ";
                case "s":
                    len_gain = 3;
                    return "sin ";
                case "S":
                    len_gain = 4;
                    return "isin ";
                case "h":
                    len_gain = 4;
                    return "sinh ";
                case "H":
                    len_gain = 5;
                    return "isinh ";
                case "c":
                    len_gain = 3;
                    return "cos ";
                case "C":
                    len_gain = 4;
                    return "icos ";
                case "o":
                    len_gain = 4;
                    return "cosh ";
                case "O":
                    len_gain = 5;
                    return "icosh ";
                case "t":
                    len_gain = 3;
                    return "tan ";
                case "T":
                    len_gain = 4;
                    return "itan ";
                case "a":
                    len_gain = 4;
                    return "tanh ";
                case "A":
                    len_gain = 5;
                    return "itanh ";
                case "q":
                    len_gain = 2;
                    return " ^ ";
                case "Q":
                    len_gain = 0;
                    return "√";
                case "z":
                    len_gain = 5;
                    return "10 ^ ";
                case "Z":
                    len_gain = 3;
                    return "e ^ ";
                case "F":
                case "f":
                    len_gain = 0;
                    return "!";
                default:
                    len_gain = 0;
                    return current_symbol;
            }
        }


        public void set_memory_present (bool present) {
            memory_label.opacity = present ? 1 : 0.2;
        }

        public void set_global_memory_present (bool present) {
            global_memory_label.opacity = present ? 1 : 0.2;
        }

        [GtkCallback]
        protected void insert_from_history (string? text) {
            main_entry.set_text (main_entry.get_text () + text);
            main_entry.set_position ((int) main_entry.text_length);
        }

        [GtkCallback]
        protected void recall_history (HistoryModel data) {
            main_entry.set_text (data.input);
            main_entry.set_position ((int) main_entry.text_length);
            main_label.set_text (data.result);
        }
    }
}
