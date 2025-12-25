namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/calculus_display.ui")]
    public class CalculusDisplay : Display {
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
        public bool integral_mode { get; set; }
        public double limit_a;
        public double limit_b;
        public double limit_x;

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
        private unowned Gtk.Entry limit_entry_a;
        [GtkChild]
        private unowned Gtk.Entry limit_entry_b;
        [GtkChild]
        private unowned Gtk.Entry limit_entry_der;
        [GtkChild]
        public unowned HistoryDisplay history_display;

        private Gtk.GestureClick right_click_gesture;
        private Gtk.EventControllerFocus focus_controller_main;
        private Gtk.EventControllerFocus focus_controller_a;
        private Gtk.EventControllerFocus focus_controller_b;
        private Gtk.EventControllerFocus focus_controller_der;
        private EntryFormatter entry_formatter;
        private unowned Gtk.Entry focused_entry;

        construct {
            entry_formatter = new EntryFormatter (main_entry);
            focused_entry = main_entry;

            settings = Pebbles.Settings.get_default ();
            settings.changed["global-angle-unit"].connect ((key) => {
                set_angle_unit (settings.global_angle_unit);
            });

            realize.connect_after (() => {
                var window = (MainWindow) get_ancestor (typeof (MainWindow));
                window.on_key_down.connect ((mode) => {
                    if (mode == Pebbles.Context.CALCULUS && focused_entry != null && !focused_entry.has_focus) {
                        focused_entry.grab_focus_without_selecting ();
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

            focus_controller_main = new Gtk.EventControllerFocus ();
            focus_controller_main.enter.connect (() => {
                focused_entry = main_entry;
            });
            main_entry.add_controller (focus_controller_main);

            focus_controller_der = new Gtk.EventControllerFocus ();
            focus_controller_der.enter.connect (() => {
                focused_entry = limit_entry_der;
            });
            limit_entry_der.add_controller (focus_controller_der);

            focus_controller_a = new Gtk.EventControllerFocus ();
            focus_controller_a.enter.connect (() => {
                focused_entry = limit_entry_a;
            });
            limit_entry_a.add_controller (focus_controller_a);

            focus_controller_b = new Gtk.EventControllerFocus ();
            focus_controller_b.enter.connect (() => {
                focused_entry = limit_entry_b;
            });
            limit_entry_b.add_controller (focus_controller_b);
        }

        public void write (string str) {
            int position = focused_entry.get_position ();
            focused_entry.do_insert_text (str, -1, ref position);
            focused_entry.set_position (position);
        }

        [GtkCallback]
        public void set_limit_a (Gtk.Editable entry) {
            limit_a = double.parse (entry.text);
        }

        [GtkCallback]
        public void set_limit_b (Gtk.Editable entry) {
            limit_b = double.parse (entry.text);
        }

        [GtkCallback]
        public void set_limit_x (Gtk.Editable entry) {
            limit_x = double.parse (entry.text);
        }

        [GtkCallback]
        public void input () {
            on_input (main_entry.text.replace (get_local_separator_symbol (), ""));
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
                    focused_entry.grab_focus_without_selecting ();
                });
            }
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

        public void all_clear () {
            show_result ("0");
            main_entry.text = "0";
            main_entry.set_position (1);

            limit_entry_a.text = "";
            limit_entry_b.text = "";
            limit_entry_der.text = "";
        }

        public void backspace () {
            int start, end;
            focused_entry.get_selection_bounds (out start, out end);

            if (start == end) {
                int pos = focused_entry.get_position ();
                if (pos > 0) {
                    focused_entry.delete_text (pos - 1, pos);
                    focused_entry.set_position (pos - 1);
                }
            } else {
                focused_entry.delete_text (start, end);
                focused_entry.set_position (start);
            }
        }

        public void set_memory_present (bool present) {
            memory_label.opacity = present ? 1 : 0.2;
        }

        public void set_global_memory_present (bool present) {
            global_memory_label.opacity = present ? 1 : 0.2;
        }

        public void show_history (HistoryModel[] history) {
            history_display.update_list (history);
        }

        public override void copy () {
            get_clipboard ().set_text (main_label.label);
        }
    }
}
