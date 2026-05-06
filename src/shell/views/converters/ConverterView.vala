// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

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

        protected string all_clear_key { get; private set; default = "<Shift>BackSpace" ; }

        private Gtk.EventControllerFocus from_entry_focus_controller;
        private Gtk.EventControllerFocus to_entry_focus_controller;
        private Gtk.EventControllerKey key_controller;

        private EntryFormatter entry_formatter_from;
        private EntryFormatter entry_formatter_to;

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

            realize.connect_after (() => {
                load_state (settings);

                var window = (MainWindow) get_ancestor (typeof (MainWindow));
                window.on_all_clear.connect ((ctx) => {
                    if (ctx == context) {
                        on_all_clear ();
                    }
                });
            });

            entry_formatter_from = new EntryFormatter (from_entry, NONE);
            entry_formatter_to = new EntryFormatter (to_entry, NONE);
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
                    (int) to_unit.selected,
                    (int) from_unit.selected
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
                    (int) from_unit.selected,
                    (int) to_unit.selected
                );
                from_entry.text = result;
            }

            save_state (settings);
        }

        [GtkCallback]
        protected void on_all_clear () {
            Idle.add_once (() => {
                focused_entry.text = "0";
                focused_entry.set_position (1);
            });
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
            from_unit.selected = settings.get_uint (key_prefix + Settings.KEY_CONV_FROM_UNIT_SUFFIX);
            to_unit.selected = settings.get_uint (key_prefix + Settings.KEY_CONV_TO_UNIT_SUFFIX);
            var window = ((MainWindow) get_ancestor (typeof (MainWindow)));
            from_entry.text = settings.get_string (key_prefix + Settings.KEY_CONV_FROM_SUFFIX);
            if (from_entry.text == "") {
                from_entry.text = "0";
            }
            to_entry.text = window.unit_converter_evaluate (context, conversion_factors,
                from_entry.text, (int) to_unit.selected, (int) from_unit.selected);
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
            settings.set_string (key_prefix + Settings.KEY_CONV_FROM_SUFFIX, from_entry.text);
            settings.set_uint (key_prefix + Settings.KEY_CONV_FROM_UNIT_SUFFIX, from_unit.selected);
            settings.set_uint (key_prefix + Settings.KEY_CONV_TO_UNIT_SUFFIX, to_unit.selected);
        }

        public override void focus_main () {
            Idle.add_once (() => {
                focused_entry.grab_focus_without_selecting ();
                focused_entry.set_position ((int) focused_entry.text_length);
            });
        }

        public override void copy () {
            if (focused_entry != null) {
                int start_pos, end_pos;
                if (to_entry == focused_entry) {
                    if (!to_entry.get_selection_bounds (out start_pos, out end_pos)) {
                        get_clipboard ().set_text (from_entry.text.replace (get_local_separator_symbol (), ""));
                    } else {
                        get_clipboard ().set_text (to_entry.text.substring (
                            start_pos, end_pos - start_pos).replace (get_local_separator_symbol (), ""));
                    }
                } else {
                    if (!from_entry.get_selection_bounds (out start_pos, out end_pos)) {
                        get_clipboard ().set_text (to_entry.text.replace (get_local_separator_symbol (), ""));
                    } else {
                        get_clipboard ().set_text (from_entry.text.substring (
                            start_pos, end_pos - start_pos).replace (get_local_separator_symbol (), ""));
                    }
                }
            }
        }
    }
}
