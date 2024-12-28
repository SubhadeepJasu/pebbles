namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/scientific_display.ui")]
    public class ScientificDisplay : Display {
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
        private unowned Gtk.Label shift_label;
        [GtkChild]
        private unowned Gtk.Label memory_label;
        [GtkChild]
        private unowned Gtk.Label global_memory_label;
        [GtkChild]
        private unowned Gtk.Label main_label;
        [GtkChild]
        public unowned Gtk.Entry main_entry;

        construct {
            visible = true;

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

                    return false;
                });

                return false;
            }, Priority.LOW);

            main_entry.get_delegate ().insert_text.connect_after ((ch, length) => {
                Idle.add (() => {
                    if (main_entry.text.has_prefix ("0") && main_entry.text != null) {
                        if (main_entry.text_length > 1) {
                            main_entry.text = main_entry.text.slice (1, main_entry.text_length);
                            main_entry.set_position ((int) main_entry.text_length);
                        }
                    }

                    if (main_entry.text.contains ("*")) {
                        Idle.add (() => {
                            main_entry.text = main_entry.text.replace ("*", " × ");
                            main_entry.set_position ((int) main_entry.text_length);
                            return false;
                        });
                    }

                    if (main_entry.text.contains ("/")) {
                        Idle.add (() => {
                            main_entry.text = main_entry.text.replace ("/", " ÷ ");
                            main_entry.set_position ((int) main_entry.text_length);
                            return false;
                        });
                    }

                    if (length > 1) {
                        return false;
                    }

                    Idle.add (() => {
                        send_fx_symbol (ch);
                        return false;
                    });
                    return false;
                });
            });

            main_entry.get_delegate ().delete_text.connect_after (() => {
                Idle.add (() => {
                    if (main_entry.text_length == 0) {
                        main_entry.text = "0";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    return false;
                });
            });
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
            }
        }

        public void all_clear () {
            show_result ("0");
            main_entry.text = "0";
            main_entry.set_position (1);
        }

        public void backspace () {
            main_entry.text = main_entry.text.substring (0, main_entry.text.length - 1);
            main_entry.set_position ((int) main_entry.text_length);
        }

        public void write (string str) {
            main_entry.text += str;
            main_entry.grab_focus_without_selecting ();
            send_fx_symbol (str);
        }

        public void send_fx_symbol (string? ch) {
            var entry_text = main_entry.text;
            var text_length = entry_text.length;
            var text_length_special = (int) main_entry.text_length;
            switch (ch) {
                case "+":
                    main_entry.text = entry_text.substring (0, text_length - 1) + " + ";
                    main_entry.set_position ((int) main_entry.text_length);
                    break;
                case "−":
                case "-":
                    main_entry.text = entry_text.substring (0, text_length_special - 1) + " − ";
                    main_entry.set_position ((int) main_entry.text_length);
                    break;
                case "÷":
                case "/":
                    main_entry.text = entry_text.substring (0, text_length_special - 1) + " ÷ ";
                    main_entry.set_position ((int) main_entry.text_length);
                    break;
                case "×":
                case "*":
                    main_entry.text = entry_text.substring (0, text_length_special - 1) + " × ";
                    main_entry.set_position ((int) main_entry.text_length);
                    break;
                case "s":
                    if (!entry_text.has_suffix ("sin ")) {
                        main_entry.text += "in ";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "S":
                    if (!entry_text.has_suffix ("isin ")) {
                        main_entry.text = entry_text.substring (0, text_length - 1) + "isin ";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "h":
                    if (!entry_text.has_suffix ("sinh ")) {
                        main_entry.text = entry_text.substring (0, text_length - 1) + "sinh ";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "H":
                    if (!entry_text.has_suffix ("isinh ")) {
                        main_entry.text = entry_text.substring (0, text_length - 1) + "isinh ";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "c":
                    if (!entry_text.has_suffix ("cos ")) {
                        main_entry.text += "os ";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "C":
                    if (!entry_text.has_suffix ("icos ")) {
                        main_entry.text = entry_text.substring (0, text_length - 1) + "icos ";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "o":
                    if (!entry_text.has_suffix ("cosh ")) {
                        main_entry.text = entry_text.substring (0, text_length - 1) + "cosh ";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "O":
                    if (!entry_text.has_suffix ("icosh ")) {
                        main_entry.text = entry_text.substring (0, text_length - 1) + "icosh ";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "t":
                    if (!entry_text.has_suffix ("tan ")) {
                        main_entry.text += "an ";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "T":
                    if (!entry_text.has_suffix ("itan ")) {
                        main_entry.text = entry_text.substring (0, text_length - 1) + "itan ";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "a":
                    if (!entry_text.has_suffix ("tanh ")) {
                        main_entry.text = entry_text.substring (0, text_length - 1) + "tanh ";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "A":
                    if (!entry_text.has_suffix ("itanh ")) {
                        main_entry.text = entry_text.substring (0, text_length - 1) + "itanh ";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "q":
                    if (!entry_text.has_suffix ("^ ")) {
                        main_entry.text = entry_text.substring (0, text_length - 1) + " ^ ";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "Q":
                    if (!entry_text.has_suffix ("√")) {
                        main_entry.text = entry_text.substring (0, text_length - 1) + "√";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "z":
                    if (!entry_text.has_suffix ("10 ^ ")) {
                        main_entry.text = entry_text.substring (0, text_length - 1) + "10 ^ ";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "Z":
                    if (!entry_text.has_suffix ("e ^ ")) {
                        main_entry.text = entry_text.substring (0, text_length - 1) + "e ^ ";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                case "F":
                case "f":
                    if (!entry_text.has_suffix ("!")) {
                        main_entry.text = entry_text.substring (0, text_length - 1) + "!";
                        main_entry.set_position ((int) main_entry.text_length);
                    }
                    break;
                default:
                    main_entry.set_position ((int) main_entry.text_length);
                    break;
            }
        }

        public void set_memory_present (bool present) {
            memory_label.opacity = present ? 1 : 0.2;
        }

        public void set_global_memory_present (bool present) {
            global_memory_label.opacity = present ? 1 : 0.2;
        }
    }
}
