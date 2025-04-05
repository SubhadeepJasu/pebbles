namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/equation_display.ui")]
    public class EquationDisplay : Display {
        public string eq_label { get; set; default = "EQ 1"; }

        [GtkChild]
        private unowned Gtk.Box eq_box;

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
                focused_entry.do_insert_text (str, str.length, ref position);
                if (focused_entry_box.entry_formatter.disabled == true) {
                    focused_entry_box.entry_formatter.disabled = false;
                }
                focused_entry.set_position (position);
            }
        }
    }
}
