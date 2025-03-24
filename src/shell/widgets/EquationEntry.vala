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
        }

        private const string CARTESIAN_MODE_TOOLTIP =
        _("<b>Cartesian Mode: <i>y = f(x)</i></b>\nClick to switch to Radial Mode");
        private const string RADIAL_MODE_TOOLTIP =
        _("<b>Radial Mode: <i>r = f(θ)</i></b>\nClick to switch to Cartesian Mode");
        private Gtk.Entry main_entry;

        public signal void change_mode (bool radial_mode);

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
                hexpand = true
            };
            main_entry.icon_release.connect ((pos) => {
                if (pos == PRIMARY) {
                    radial_mode = !radial_mode;
                    mode_changed (radial_mode);
                    main_entry.grab_focus_without_selecting ();
                    main_entry.set_position ((int) main_entry.text_length);
                } else {
                    var list = get_parent () as Gtk.Box;
                    list.remove (this);
                }
            });
            main_entry.notify["has-focus"].connect (() => {
                mode_changed (radial_mode);
            });
            main_entry.get_delegate ().insert_text.connect_after ((ch, length) => {
                var text = main_entry.text;
                Idle.add (() => {
                    if (text.length > 1 && text.has_prefix ("0")) {
                        main_entry.text = text.substring (1);
                        main_entry.set_position (1);
                        return Source.REMOVE;
                    }

                    if (length > 1) {
                        return Source.REMOVE;
                    }

                    Idle.add (() => {
                        if (main_entry.text_length > 1)
                        replace_inserted_character (main_entry.text, main_entry.text_length, main_entry.get_position ());
                        return Source.REMOVE;
                    });
                    return Source.REMOVE;
                });
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

        public void replace_inserted_character (string text, uint text_length, int caret_pos) {
            var symbols = split_utf8 (text, text_length);
            var current_symbol = symbols[caret_pos];
            if (current_symbol == null) {
                return;
            }
            var previous_symbol = "";
            var previous_caret_pos = caret_pos - 1;
            for (int i = caret_pos - 1; i >= 0; i--) {
                if (symbols[i] != " ") {
                    previous_symbol = symbols[i];
                    previous_caret_pos = i;
                    break;
                }
            }

            print ("%s, %s\n", previous_symbol, current_symbol);

            bool double_replaced;
            int len_gain;
            var replacement = find_replacement (current_symbol, previous_symbol, out double_replaced, out len_gain);
            symbols[caret_pos] = replacement;
            if (double_replaced) {
                symbols[previous_caret_pos] = "";
                if (previous_caret_pos > 0 && symbols[previous_caret_pos - 1] == " ") {
                    symbols[previous_caret_pos - 1] = "";
                }

                if (previous_caret_pos < text_length - 1 && symbols[previous_caret_pos + 1] == " ") {
                    symbols[previous_caret_pos + 1] = "";
                }
            }

            main_entry.text = string.joinv ("", symbols);
            if (double_replaced) {
                main_entry.set_position (caret_pos - 1);
            } else {
                main_entry.set_position (caret_pos + len_gain);
            }
        }

        private string[] split_utf8 (string text, uint text_length) {
            var result = new string[text_length + 1];
            var j = 0;

            var sb = new StringBuilder ();
            for (int i = 0; i <= text.length; i++) {
                if ((text[i] & 0xC0) != 0x80) { // Prevent commiting if its a continuation bit
                    result[j++] = sb.str + "";
                    sb.erase (0, sb.len);
                }

                if (text[i] != '\0') {
                    sb.append_c (text[i]);
                }
            }

            return result;
        }

        public string find_replacement (string current_symbol, string previous_symbol, out bool double_replaced, out int len_gain) {
            double_replaced = false;
            switch (current_symbol) {
                case "x":
                    len_gain = 0;
                    if (radial_mode) {
                        return "θ";
                    } else {
                        return "x";
                    }
                case "+":
                    len_gain = 2;
                    return " + ";
                case "−":
                case "-":
                    len_gain = 2;
                    return " − ";
                case "÷":
                case "/":
                    len_gain = 2;
                    return " ÷ ";
                case "×":
                case "*":
                    len_gain = 2;
                    if (previous_symbol == "×") {
                        double_replaced = true;
                        return " ^ ";
                    }

                    return " × ";
                case "s":
                    len_gain = 3;
                    return "sin ";
                case "S":
                    len_gain = 4;
                    return "isin ";
                case "h":
                    len_gain = 4;
                    return "sinh ";
                case "H":
                    len_gain = 5;
                    return "isinh ";
                case "c":
                    len_gain = 3;
                    return "cos ";
                case "C":
                    len_gain = 4;
                    return "icos ";
                case "o":
                    len_gain = 4;
                    return "cosh ";
                case "O":
                    len_gain = 5;
                    return "icosh ";
                case "t":
                    len_gain = 3;
                    return "tan ";
                case "T":
                    len_gain = 4;
                    return "itan ";
                case "a":
                    len_gain = 4;
                    return "tanh ";
                case "A":
                    len_gain = 5;
                    return "itanh ";
                case "q":
                    len_gain = 2;
                    return " ^ ";
                case "Q":
                    len_gain = 0;
                    return "√";
                case "z":
                    len_gain = 5;
                    return "10 ^ ";
                case "Z":
                    len_gain = 3;
                    return "e ^ ";
                case "F":
                case "f":
                    len_gain = 0;
                    return "!";
                default:
                    len_gain = 0;
                    return current_symbol;
            }
        }

    }
}
