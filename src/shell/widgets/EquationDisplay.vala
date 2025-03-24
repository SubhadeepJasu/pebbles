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
        }

        private void change_mode_handler (bool mode) {
            change_mode (mode);
        }
    }
}
