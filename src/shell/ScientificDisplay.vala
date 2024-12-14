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
        private unowned Gtk.Label main_label;
        [GtkChild]
        private unowned Gtk.Entry main_entry;

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
                    main_entry.grab_focus ();

                    return false;
                });

                return false;
            }, Priority.LOW);

            main_entry.get_delegate ().insert_text.connect_after ((ch, length) => {
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
                    return;
                }

                switch (ch) {
                    case "+":
                        Idle.add (() => {
                            main_entry.text = main_entry.text.substring (0, main_entry.text_length - 1) + " + ";
                            main_entry.set_position ((int) main_entry.text_length);
                            return false;
                        });
                        break;
                    case "-":
                        Idle.add (() => {
                            main_entry.text = main_entry.text.substring (0, main_entry.text_length - 1) + " − ";
                            main_entry.set_position ((int) main_entry.text_length);
                            return false;
                        });
                        break;
                    case "s":
                        if (!main_entry.text.has_suffix ("sin ")) {
                            Idle.add (() => {
                                main_entry.text += "in ";
                                main_entry.set_position ((int) main_entry.text_length);
                                return false;
                            });
                        }
                        break;
                    case "S":
                        if (!main_entry.text.has_suffix ("isin ")) {
                            Idle.add (() => {
                                main_entry.text = main_entry.text.substring (0, main_entry.text_length - 1) + "isin ";
                                main_entry.set_position ((int) main_entry.text_length);
                                return false;
                            });
                        }
                        break;
                    case "h":
                        if (!main_entry.text.has_suffix ("sinh ")) {
                            Idle.add (() => {
                                main_entry.text = main_entry.text.substring (0, main_entry.text_length - 1) + "sinh ";
                                main_entry.set_position ((int) main_entry.text_length);
                                return false;
                            });
                        }
                        break;
                    case "H":
                        if (!main_entry.text.has_suffix ("isinh ")) {
                            Idle.add (() => {
                                main_entry.text = main_entry.text.substring (0, main_entry.text_length - 1) + "isinh ";
                                main_entry.set_position ((int) main_entry.text_length);
                                return false;
                            });
                        }
                        break;
                    case "c":
                        if (!main_entry.text.has_suffix ("cos ")) {
                            Idle.add (() => {
                                main_entry.text += "os ";
                                main_entry.set_position ((int) main_entry.text_length);
                                return false;
                            });
                        }
                        break;
                    case "C":
                        if (!main_entry.text.has_suffix ("icos ")) {
                            Idle.add (() => {
                                main_entry.text = main_entry.text.substring (0, main_entry.text_length - 1) + "icos ";
                                main_entry.set_position ((int) main_entry.text_length);
                                return false;
                            });
                        }
                        break;
                    case "o":
                        if (!main_entry.text.has_suffix ("cosh ")) {
                            Idle.add (() => {
                                main_entry.text = main_entry.text.substring (0, main_entry.text_length - 1) + "cosh ";
                                main_entry.set_position ((int) main_entry.text_length);
                                return false;
                            });
                        }
                        break;
                    case "O":
                        if (!main_entry.text.has_suffix ("icosh ")) {
                            Idle.add (() => {
                                main_entry.text = main_entry.text.substring (0, main_entry.text_length - 1) + "icosh ";
                                main_entry.set_position ((int) main_entry.text_length);
                                return false;
                            });
                        }
                        break;
                    case "t":
                        if (!main_entry.text.has_suffix ("tan ")) {
                            Idle.add (() => {
                                main_entry.text += "an ";
                                main_entry.set_position ((int) main_entry.text_length);
                                return false;
                            });
                        }
                        break;
                    case "T":
                        if (!main_entry.text.has_suffix ("itan ")) {
                            Idle.add (() => {
                                main_entry.text = main_entry.text.substring (0, main_entry.text_length - 1) + "itan ";
                                main_entry.set_position ((int) main_entry.text_length);
                                return false;
                            });
                        }
                        break;
                    case "a":
                        if (!main_entry.text.has_suffix ("tanh ")) {
                            Idle.add (() => {
                                main_entry.text = main_entry.text.substring (0, main_entry.text_length - 1) + "tanh ";
                                main_entry.set_position ((int) main_entry.text_length);
                                return false;
                            });
                        }
                        break;
                    case "A":
                        if (!main_entry.text.has_suffix ("itanh ")) {
                            Idle.add (() => {
                                main_entry.text = main_entry.text.substring (0, main_entry.text_length - 1) + "itanh ";
                                main_entry.set_position ((int) main_entry.text_length);
                                return false;
                            });
                        }
                        break;
                }
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
    }
}