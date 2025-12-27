// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>

namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/equation_display.ui")]
    public class EquationDisplay : Display {
        private Pebbles.Settings settings;
        public string eq_label { get; set; default = "EQ 1"; }
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
        private unowned Gtk.Box eq_box;
        [GtkChild]
        private unowned Gtk.Label deg_label;
        [GtkChild]
        private unowned Gtk.Label rad_label;
        [GtkChild]
        private unowned Gtk.Label grad_label;
        [GtkChild]
        private unowned Gtk.Label shift_label;
        [GtkChild]
        private unowned Gtk.Label global_memory_label;

        public signal void change_mode (bool radial_mode);

        private EquationModel[] _eq_array;
        public unowned EquationModel[] equations {
            get {
                var eqlist = new List<EquationModel> ();
                for (var entry = eq_box.get_first_child (); entry != null; entry = entry.get_next_sibling ()) {
                    var _entry = entry as EquationEntry;
                    eqlist.append (_entry.equation);
                }

                var n = (int) eqlist.length ();

                if (_eq_array == null) {
                    _eq_array = new EquationModel[n];
                }

                if (_eq_array.length != n) {
                    _eq_array.resize (n);
                }

                for (var i = 0; i < n; i++) {
                    _eq_array[i] = eqlist.nth_data (i);
                }

                return _eq_array;
            }
        }

        private int index = 0;
        private unowned EquationEntry focused_entry_box;
        private unowned Gtk.Entry focused_entry;

        construct {
            settings = Pebbles.Settings.get_default ();
            settings.changed["global-angle-unit"].connect ((key) => {
                set_angle_unit (settings.global_angle_unit);
            });

            set_angle_unit (settings.global_angle_unit);

            Idle.add_once (() => {
                var last_inputs = settings.last_input_graphing;
                if (last_inputs.length > 0) {
                    foreach (var expr in last_inputs) {
                        var entry = new EquationEntry (index);
                        eq_box.append (entry);
                        var parts = expr.split (";");
                        if (parts.length == 2) {
                            var expression = parts[0].substring (expr.index_of_char ('=') + 2);
                            var radial_coord_mode = bool.parse (parts[1]);
                            entry.equation = new EquationModel (index, expression, radial_coord_mode);
                            entry.change_mode.connect (change_mode_handler);
                            entry.focused.connect (focus_handler);
                            index += 1;
                        } else {
                            warning ("Saved graph euqation seems corrupted");
                            settings.reset ("last-input-graphing");
                            break;
                        }
                    }
                } else {
                    add_equation ();
                }
            });
        }

        public void add_equation () {
            var ex = eq_box.get_last_child () as EquationEntry;
            if (ex != null) {
                index = ex.index + 1;
            }

            var entry = new EquationEntry (index);
            eq_box.append (entry);
            entry.grab_focus ();
            entry.change_mode.connect (change_mode_handler);
            entry.focused.connect (focus_handler);
        }

        private void change_mode_handler (bool mode) {
            change_mode (mode);
        }

        private void focus_handler (EquationEntry entry_box, Gtk.Entry entry) {
            focused_entry = entry;
            focused_entry_box = entry_box;
            eq_label = "EQ " + (focused_entry_box.index + 1).to_string ();
        }

        public void all_clear () {
            if (focused_entry != null) {
                focused_entry.text = "0";
                focused_entry.set_position (1);
            }
        }

        public void backspace () {
            if (focused_entry != null) {
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
        }

        public void write (string str, bool disable_auto_insert = false) {
            if (focused_entry != null) {
                int position = focused_entry.get_position ();
                if (disable_auto_insert) {
                    focused_entry_box.entry_formatter.disabled = true;
                }
                focused_entry.do_insert_text (str, -1, ref position);
                if (focused_entry_box.entry_formatter.disabled == true) {
                    focused_entry_box.entry_formatter.disabled = false;
                }
                focused_entry.set_position (position);
            }
        }

        public void navigate (bool direction) {
            if (direction) {
                EquationEntry? prev = focused_entry_box.get_prev_sibling () as EquationEntry?;
                if (prev != null) {
                    prev.grab_focus ();
                }
            } else {
                EquationEntry? next = focused_entry_box.get_next_sibling () as EquationEntry?;
                if (next != null) {
                    next.grab_focus ();
                }
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

        public void set_global_memory_present (bool present) {
            global_memory_label.opacity = present ? 1 : 0.2;
        }

        public override void copy () {
            if (focused_entry != null) {
                get_clipboard ().set_text (focused_entry.text);
            }
        }
    }
}
