namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/equation_display.ui")]
    public class EquationDisplay : Display {
        public string eq_label { get; set; default = "EQ 1"; }

        [GtkChild]
        private unowned Gtk.Box eq_box;

        public signal void change_mode (bool radial_mode);

        construct {

        }

        public void add_equation () {
            var entry = new EquationEntry ();
            eq_box.append (entry);
            entry.grab_focus ();
            entry.change_mode.connect (change_mode_handler);
        }

        private void change_mode_handler (bool mode) {
            change_mode (mode);
        }
    }
}
