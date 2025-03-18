namespace Pebbles {
    public class EquationEntry : Gtk.Box {
        private bool _radial_mode;
        public bool radial_mode {
            get {
                return _radial_mode;
            }

            set {
                _radial_mode = value;
                main_entry.primary_icon_name = value ? "radial-eq-symbolic" : "linear-eq-symbolic";
                main_entry.primary_icon_tooltip_markup = value ? RADIAL_MODE_TOOLTIP : CARTESIAN_MODE_TOOLTIP;
            }
        }

        private const string CARTESIAN_MODE_TOOLTIP =
        _("<b>Cartesian Mode: <i>y = f(x)</i></b>\nClick to switch to Radial Mode");
        private const string RADIAL_MODE_TOOLTIP =
        _("<b>Radial Mode: <i>r = f(θ)</i></b>\nClick to switch to Cartesian Mode");
        private Gtk.Entry main_entry;

        public signal void change_mode (bool radial_mode);

        public EquationEntry () {
            Object (
                orientation: Gtk.Orientation.HORIZONTAL,
                spacing: 4,
                valign: Gtk.Align.START
            );
        }

        construct {
            add_css_class ("equation-entry");

            var color_box = new Gtk.Box (VERTICAL, 0) {
                margin_top = 8,
                margin_bottom = 8
            };
            append (color_box);
            color_box.add_css_class ("equation-entry-indicator");

            var color_indicator = new Gtk.DrawingArea () {
                width_request = 8,
                vexpand = true
            };
            color_box.append (color_indicator);

            main_entry = new Gtk.Entry () {
                primary_icon_name = "linear-eq-symbolic",
                primary_icon_tooltip_markup = CARTESIAN_MODE_TOOLTIP,
                secondary_icon_name = "edit-delete-symbolic",
                secondary_icon_tooltip_text = _("Delete equation"),
                hexpand = true
            };
            main_entry.icon_release.connect ((pos) => {
                if (pos == PRIMARY) {
                    radial_mode = !radial_mode;
                    mode_changed (radial_mode);
                }
            });
            main_entry.notify["has-focus"].connect (() => {
                mode_changed (radial_mode);
            });
            append (main_entry);
        }

        public override bool grab_focus () {
            mode_changed (radial_mode);
            return main_entry.grab_focus ();
        }

        private void mode_changed (bool radial_mode) {
            change_mode (radial_mode);
            if (radial_mode) {
                main_entry.text = main_entry.text.replace ("x", "θ");
                main_entry.text = main_entry.text.replace ("X", "θ");
            } else {
                main_entry.text = main_entry.text.replace ("θ", "x");
                main_entry.text = main_entry.text.replace ("Θ", "x");
                main_entry.text = main_entry.text.replace ("ϴ", "x");
            }
        }
    }
}
