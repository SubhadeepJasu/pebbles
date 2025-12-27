namespace Pebbles {
    public class EquationEntry : Gtk.Box {
        public int index { get; construct; }
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

        private EquationModel _equation;
        public EquationModel? equation {
            get {
                _equation = new EquationModel (index, main_entry.text, radial_mode);
                return _equation;
            }

            set {
                _equation = value;
                main_entry.text = _equation.expression;
                radial_mode = _equation.radial_coord_mode;
                entry_formatter.polar_mode = radial_mode;
                main_entry.primary_icon_name = radial_mode ? "radial-eq-symbolic" : "linear-eq-symbolic";
                main_entry.primary_icon_tooltip_markup = radial_mode ? RADIAL_MODE_TOOLTIP : CARTESIAN_MODE_TOOLTIP;
            }
        }

        private const string CARTESIAN_MODE_TOOLTIP =
        _("<b>Cartesian Mode: <i>y = f(x)</i></b>\nClick to switch to Radial Mode");
        private const string RADIAL_MODE_TOOLTIP =
        _("<b>Radial Mode: <i>r = f(θ)</i></b>\nClick to switch to Cartesian Mode");
        private Gtk.Entry main_entry;

        public EntryFormatter entry_formatter;

        public signal void change_mode (bool radial_mode);
        public signal void focused (EquationEntry entry_box, Gtk.Entry entry);

        public EquationEntry (int index) {
            Object (
                index: index,
                orientation: Gtk.Orientation.HORIZONTAL,
                spacing: 4,
                valign: Gtk.Align.START,
                margin_top: 4
            );
        }

        construct {
            add_css_class ("equation-entry");

            var color_box = new Gtk.Box (VERTICAL, 0) {
                margin_top = 2,
                margin_bottom = 2,
                vexpand = true
            };
            append (color_box);
            color_box.add_css_class ("equation-entry-indicator");

            var color_indicator = new Gtk.DrawingArea () {
                width_request = 8,
                vexpand = true
            };
            color_box.append (color_indicator);
            color_indicator.set_draw_func (draw_indicator);

            main_entry = new Gtk.Entry () {
                primary_icon_name = "linear-eq-symbolic",
                primary_icon_tooltip_markup = CARTESIAN_MODE_TOOLTIP,
                secondary_icon_name = "edit-delete-symbolic",
                secondary_icon_tooltip_text = _("Delete equation"),
                hexpand = true,
                text = "0"
            };
            main_entry.icon_release.connect ((pos) => {
                if (pos == PRIMARY) {
                    radial_mode = !radial_mode;
                    mode_changed (radial_mode);
                    entry_formatter.polar_mode = radial_mode;
                    main_entry.grab_focus_without_selecting ();
                    main_entry.set_position ((int) main_entry.text_length);
                } else {
                    var list = get_parent () as Gtk.Box;
                    list.remove (this);
                }
            });
            main_entry.notify["has-focus"].connect (() => {
                mode_changed (radial_mode);
                Idle.add_once (() => {
                    focused (this, main_entry);
                });
            });
            entry_formatter = new EntryFormatter (main_entry);
            append (main_entry);
        }

        public override bool grab_focus () {
            mode_changed (radial_mode);
            Idle.add_once (() => {
                focused (this, main_entry);
            });

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

        private void draw_indicator (Gtk.DrawingArea area, Cairo.Context cr, int width, int height) {
            double degrees = Math.PI / 180.0;
            double radius = 4.0;
            cr.new_sub_path ();
            cr.arc (width - radius, radius, radius, -90 * degrees, 0);
            cr.arc (width - radius, height - radius, radius, 0, 90 * degrees);
            cr.arc (radius, height - radius, radius, 90 * degrees, 180 * degrees);
            cr.arc (radius, radius, radius, 180 * degrees, 270 * degrees);
            cr.close_path ();

            cr.clip ();

            var hex = PALETTE[index].substring (1);
            cr.set_source_rgb (
                (double) uint.parse (hex.substring (0, 2), 16) / 256,
                (double) uint.parse (hex.substring (2, 2), 16) / 256,
                (double) uint.parse (hex.substring (4, 2), 16) / 256
            );

            cr.rectangle (0, 0, width, height);
            cr.fill ();
        }
    }
}
