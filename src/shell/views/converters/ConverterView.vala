namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/converter_view.ui")]
    public abstract class ConverterView : View {
        public Gtk.Orientation orientation { get; private set; }
        private bool _collapsed;
        public bool collapsed {
            get {
                return _collapsed;
            }

            set construct {
                _collapsed = value;
                orientation = value ? Gtk.Orientation.VERTICAL : Gtk.Orientation.HORIZONTAL;
            }
        }

        public string title { get; protected set; }
        public string icon_name { get; protected set; }
        public Gtk.StringList unit_options { get; protected set; }
        public double[] conversion_factors;

        protected Pebbles.Settings settings;
        private bool allow_change = true;
        private unowned Gtk.Entry focused_entry;
        private bool init = false;

        [GtkChild]
        protected unowned Gtk.Entry from_entry;
        [GtkChild]
        protected unowned Gtk.Entry to_entry;
        [GtkChild]
        protected unowned Gtk.DropDown from_unit;
        [GtkChild]
        protected unowned Gtk.DropDown to_unit;
        [GtkChild]
        protected unowned Gtk.Label additional_label;

        private Gtk.EventControllerFocus from_entry_focus_controller;
        private Gtk.EventControllerFocus to_entry_focus_controller;
        private Gtk.EventControllerKey key_controller;

        construct {
            settings = Pebbles.Settings.get_default ();
            from_entry_focus_controller = new Gtk.EventControllerFocus ();
            from_entry.add_controller (from_entry_focus_controller);
            from_entry_focus_controller.enter.connect (() => {
                from_entry.remove_css_class ("conversion-text-box-focused");
                focused_entry = from_entry;
            });
            from_entry_focus_controller.leave.connect (() => {
                from_entry.add_css_class ("conversion-text-box-focused");
            });
            focused_entry = from_entry;

            to_entry_focus_controller = new Gtk.EventControllerFocus ();
            to_entry.add_controller (to_entry_focus_controller);
            to_entry_focus_controller.enter.connect (() => {
                to_entry.remove_css_class ("conversion-text-box-focused");
                focused_entry = to_entry;
            });
            to_entry_focus_controller.leave.connect (() => {
                to_entry.add_css_class ("conversion-text-box-focused");
            });

            key_controller = new Gtk.EventControllerKey ();
            add_controller (key_controller);

            key_controller.key_pressed.connect ((keyval, keycode, modifier) => {
                var ctrl_held = (modifier & Gdk.ModifierType.CONTROL_MASK) != 1;

                focused_entry.grab_focus_without_selecting ();

                switch (keyval) {
                    case Gdk.Key.C:
                    case Gdk.Key.c:
                        write_answer_to_clipboard ();
                        return true;
                    case Gdk.Key.Tab:
                    case 65056:
                        if (from_entry.has_focus) {
                            to_entry.grab_focus_without_selecting ();
                            to_entry.set_position ((int) to_entry.text_length);
                            focused_entry = to_entry;
                        } else {
                            from_entry.grab_focus_without_selecting ();
                            focused_entry = from_entry;
                            from_entry.set_position ((int) from_entry.text_length);
                        }
                        break;
                    case Gdk.Key.Up:
                        from_entry.grab_focus_without_selecting ();
                        focused_entry = from_entry;
                        from_entry.set_position ((int) from_entry.text_length);
                        break;
                    case Gdk.Key.Down:
                        to_entry.grab_focus_without_selecting ();
                        focused_entry = to_entry;
                        to_entry.set_position ((int) to_entry.text_length);
                        break;
                    case Gdk.Key.Return:
                        interchange_entries ();
                        //  interchange_button.add_css_class ("pressed");
                        break;
                }

                return false;
            });

            realize.connect (() => {
                load_state (settings);
            });
        }

        public void write_answer_to_clipboard () {
            var clipboard = get_clipboard ();
            if (focused_entry == from_entry) {
                string last_answer = to_entry.get_text ().replace (get_local_separator_symbol (), "");
                clipboard.set_text (last_answer);
            } else {
                string last_answer = from_entry.get_text ().replace (get_local_separator_symbol (), "");
                clipboard.set_text (last_answer);
            }
        }

        [GtkCallback]
        protected void interchange_entries () {
            allow_change = false;
            uint temp = to_unit.selected;
            to_unit.selected = from_unit.selected;
            from_unit.selected = temp;
            var window = ((MainWindow) get_ancestor (typeof (MainWindow)));
            var input_text = from_entry.text;
            string result = window.unit_converter_evaluate (
                context,
                conversion_factors,
                input_text,
                (int) from_unit.selected,
                (int) to_unit.selected
            );
            to_entry.text = result;

            save_state (settings);
            allow_change = true;
        }

        [GtkCallback]
        protected void from_entry_change_handler () {
            if (focused_entry == from_entry && allow_change) {
                var window = ((MainWindow) get_ancestor (typeof (MainWindow)));
                var input_text = from_entry.text;
                string result = window.unit_converter_evaluate (
                    context,
                    conversion_factors,
                    input_text,
                    (int) from_unit.selected,
                    (int) to_unit.selected
                );
                to_entry.text = result;
            }

            save_state (settings);
        }

        [GtkCallback]
        protected void to_entry_change_handler () {
            if (focused_entry == to_entry && allow_change) {
                var window = ((MainWindow) get_ancestor (typeof (MainWindow)));
                var input_text = to_entry.text;
                string result = window.unit_converter_evaluate (
                    context,
                    conversion_factors,
                    input_text,
                    (int) to_unit.selected,
                    (int) from_unit.selected
                );
                from_entry.text = result;
            }

            save_state (settings);
        }

        [GtkCallback]
        protected void on_all_clear () {
            focused_entry.text = "0";
        }

        [GtkCallback]
        protected void on_backspace () {
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

        [GtkCallback]
        public void on_click_button (Gtk.Button btn) {
            write (btn.name);
        }

        [GtkCallback]
        public void on_click_radix () {
            write (get_local_radix_symbol ());
        }

        private void write (string str) {
            int position = focused_entry.get_position ();
            focused_entry.do_insert_text (str, str.length, ref position);
            focused_entry.set_position (position);
        }

        protected void load_state (Pebbles.Settings settings) {
            allow_change = false;
            var key_prefix = context.replace (".", "-");

            from_entry.text = settings.get_string (key_prefix + "-from");
            from_unit.selected = settings.get_uint (key_prefix + "-from-unit");
            to_unit.selected = settings.get_uint (key_prefix + "-to-unit");
            var window = ((MainWindow) get_ancestor (typeof (MainWindow)));
            to_entry.text = window.unit_converter_evaluate (context, conversion_factors,
                from_entry.text, (int) from_unit.selected, (int) to_unit.selected);
            allow_change = true;
            focused_entry = from_entry;
            focused_entry.grab_focus_without_selecting ();
            focused_entry.set_position ((int) focused_entry.text_length);
            init= true;
        }

        protected void save_state (Pebbles.Settings settings) {
            if (!init) {
                return;
            }

            var key_prefix = context.replace (".", "-");
            settings.set_string (key_prefix + "-from", from_entry.text);
            settings.set_uint (key_prefix + "-from-unit", from_unit.selected);
            settings.set_uint (key_prefix + "-to-unit", to_unit.selected);
        }

        public override void focus_main () {
            Idle.add_once (() => {
                focused_entry.grab_focus_without_selecting ();
                focused_entry.set_position ((int) focused_entry.text_length);
            });
        }
    }
}
