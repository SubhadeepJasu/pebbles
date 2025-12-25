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
        private EntryFormatter entry_formatter;

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

            entry_formatter = new EntryFormatter (main_entry);

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

                window.on_all_clear.connect ((ctx) => {
                    if (ctx == context) {
                        all_clear ();
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
            on_input (main_entry.text.replace (get_local_separator_symbol (), ""));
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
            main_entry.do_insert_text (str, -1, ref position);
            main_entry.set_position (position);
        }

        public void set_memory_present (bool present) {
            memory_label.opacity = present ? 1 : 0.2;
        }

        public void set_global_memory_present (bool present) {
            global_memory_label.opacity = present ? 1 : 0.2;
        }

        [GtkCallback]
        protected void insert_from_history (string? text) {
            write (text);
        }

        [GtkCallback]
        protected void recall_history (HistoryModel data) {
            main_entry.set_text (data.input);
            main_entry.set_position ((int) main_entry.text_length);
            main_label.set_text (data.result);
        }

        public override void copy () {
            get_clipboard ().set_text (main_label.label);
        }
    }
}
