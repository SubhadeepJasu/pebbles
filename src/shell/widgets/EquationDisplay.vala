namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/equation_display.ui")]
    public class EquationDisplay : Display {
        public string eq_label { get; set; default = "EQ 1"; }

        [GtkChild]
        private unowned Gtk.Box eq_box;

        public signal void change_mode (bool radial_mode);

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

        public void get_equations () {
            for (var entry = eq_box.get_first_child (); entry != null; entry = entry.get_next_sibling ()) {
                var _entry = entry as EquationEntry;
                print (_entry.equation.to_string () + "\n");
            }
        }

        private void change_mode_handler (bool mode) {
            change_mode (mode);
        }
    }
}
