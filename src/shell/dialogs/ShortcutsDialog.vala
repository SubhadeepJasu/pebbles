namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/shortcuts_dialog.ui")]
    public class ShortcutsDialog : Adw.Dialog {
        [GtkChild]
        private unowned Gtk.Box common_box;
        [GtkChild]
        private unowned Gtk.Box scientific_box;
        [GtkChild]
        private unowned Gtk.Box statistics_box;
        [GtkChild]
        private unowned Gtk.Box calculus_box;
        [GtkChild]
        private unowned Gtk.Box programmer_box;
        [GtkChild]
        private unowned Gtk.Box converter_box;
        construct {
            var control_scheme = new ControlScheme ();

            uint8 i = 0;
            for (; i < control_scheme.common.length[0]; i++) {
                common_box.append (new Granite.AccelLabel (control_scheme.common[i, 0], control_scheme.common[i, 1]));
            }

            for (i = 0; i < control_scheme.scientific.length[0]; i++) {
                scientific_box.append (new Granite.AccelLabel (control_scheme.scientific[i, 0], control_scheme.scientific[i, 1]));
            }

            for (i = 0; i < control_scheme.statistics.length[0]; i++) {
                statistics_box.append (new Granite.AccelLabel (control_scheme.statistics[i, 0], control_scheme.statistics[i, 1]));
            }

            for (i = 0; i < control_scheme.calculus.length[0]; i++) {
                calculus_box.append (new Granite.AccelLabel (control_scheme.calculus[i, 0], control_scheme.calculus[i, 1]));
            }

            for (i = 0; i < control_scheme.programmer.length[0]; i++) {
                programmer_box.append (new Granite.AccelLabel (control_scheme.programmer[i, 0], control_scheme.programmer[i, 1]));
            }

            for (i = 0; i < control_scheme.converter.length[0]; i++) {
                converter_box.append (new Granite.AccelLabel (control_scheme.converter[i, 0], control_scheme.converter[i, 1]));
            }
        }
    }
}
