/*-
 * Copyright (c) 2017-2020 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright (c) 2017-2020 Saunak Biswas  <saunakbis97@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 *              Saunak Biswas  <saunakbis97@gmail.com>
 */

namespace Pebbles {
    public class ScientificDisplay : Gtk.Grid {
        // Status bar
        Gtk.Grid lcd_status_bar;
        Gtk.Label deg_label;
        Gtk.Label rad_label;
        Gtk.Label grad_label;
        Gtk.Label memory_label;
        Gtk.Label shift_label;

        // Answer label
        public Gtk.Label answer_label;

        // Input entry
        public Gtk.Entry input_entry;

        // Angle mode
        GlobalAngleUnit angle_mode;

        ScientificView sci_view;
        public ScientificDisplay (ScientificView view) {
            this.sci_view = view;
            sci_display_make_ui ();
        }
        private void sci_display_make_ui () {
            var settings = Settings.get_default ();

            // Stylize background;
            get_style_context ().add_class ("Pebbles_Display_Unit_Bg");

            // Make status bar
            lcd_status_bar = new Gtk.Grid ();
            deg_label      = new Gtk.Label ("DEG");
            deg_label.get_style_context ().add_class ("pebbles_h4");
            rad_label      = new Gtk.Label ("RAD");
            rad_label.get_style_context ().add_class ("pebbles_h4");
            grad_label     = new Gtk.Label ("GRA");
            grad_label.get_style_context ().add_class ("pebbles_h4");
            memory_label   = new Gtk.Label ("M");
            memory_label.set_halign (Gtk.Align.CENTER);
            memory_label.hexpand = true;
            memory_label.get_style_context ().add_class ("pebbles_h4");
            memory_label.set_opacity (0.2);
            shift_label    = new Gtk.Label (_("SHIFT"));
            shift_label.get_style_context ().add_class ("pebbles_h4");
            shift_label.set_opacity (0.2);
            shift_label.set_halign (Gtk.Align.END);
            shift_label.hexpand = true;

            var angle_mode_display = new Gtk.Grid ();
            angle_mode_display.attach (deg_label,  0, 0, 1, 1);
            angle_mode_display.attach (rad_label,  1, 0, 1, 1);
            angle_mode_display.attach (grad_label, 2, 0, 1, 1);
            angle_mode_display.column_spacing = 10;
            angle_mode_display.set_halign (Gtk.Align.START);

            lcd_status_bar.attach (angle_mode_display, 0, 0, 1, 1);
            lcd_status_bar.attach (memory_label, 1, 0, 1, 1);
            lcd_status_bar.attach (shift_label, 2, 0, 1, 1);
            lcd_status_bar.width_request = 200;
            lcd_status_bar.set_halign (Gtk.Align.FILL);
            lcd_status_bar.hexpand = true;

            // Make LCD Answer label
            answer_label = new Gtk.Label (settings.load_last_display_values ? settings.sci_output_text : "0");
            answer_label.set_halign (Gtk.Align.END);
            answer_label.set_valign (Gtk.Align.END);
            answer_label.vexpand = true;
            var scrollable = new Gtk.ScrolledWindow (null, null);
            scrollable.add (answer_label);
            scrollable.propagate_natural_height = true;
            scrollable.shadow_type = Gtk.ShadowType.NONE;
            scrollable.get_style_context ().add_class ("pebbles_h1");

            // Make Input entry
            input_entry = new Gtk.Entry ();

            input_entry.set_has_frame (false);
            input_entry.set_text (settings.load_last_display_values ? settings.sci_input_text : "0");
            input_entry.get_style_context ().add_class ("pebbles_h2");
            input_entry.set_halign (Gtk.Align.FILL);
            input_entry.hexpand = true;
            input_entry.margin_bottom = 1;
            input_entry.activate.connect (() => {
                display_off ();
                get_answer_evaluate ();
                if (input_entry.get_text ().length == 0 && input_entry.get_text () != "0") {
                    input_entry.set_text ("0");
                }
            });
            input_entry.changed.connect (() => {
                if (input_entry.get_text ().has_prefix ("0") && input_entry.get_text () != null) {
                    if (input_entry.get_text ().length != 1) {
                        input_entry.set_text (input_entry.get_text ().slice (1, input_entry.get_text().length));
                    }
                }
            });
            input_entry.key_release_event.connect (() => {
                display_on ();
                return false;
            });
            input_entry.copy_clipboard.connect(() => {
                this.write_answer_to_clipboard();
            });

            // Make seperator
            Gtk.Separator lcd_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            lcd_separator.set_opacity (0.6);

            // Put it together
            attach (lcd_status_bar, 0, 0, 1, 1);
            attach (scrollable, 0, 1, 1, 1);
            attach (lcd_separator, 0, 2, 1, 1);
            attach (input_entry, 0, 3, 1, 1);

            width_request = 300;
        }

        public void set_shift_enable (bool s_on) {
            if (s_on) {
                shift_label.set_opacity (1);
            }
            else {
                shift_label.set_opacity (0.2);
            }
        }

        public void set_angle_status (int state) {
            switch (state) {
                case 1 :
                    deg_label.set_opacity  (0.2);
                    rad_label.set_opacity  (1);
                    grad_label.set_opacity (0.2);
                    angle_mode = GlobalAngleUnit.RAD;
                    break;
                case 2 :
                    deg_label.set_opacity  (0.2);
                    rad_label.set_opacity  (0.2);
                    grad_label.set_opacity (1);
                    angle_mode = GlobalAngleUnit.GRAD;
                    break;
                default :
                    deg_label.set_opacity  (1);
                    rad_label.set_opacity  (0.2);
                    grad_label.set_opacity (0.2);
                    angle_mode = GlobalAngleUnit.DEG;
                    break;
            }
        }

        public void set_memory_status (bool state) {
            if (state) {
                memory_label.set_opacity (1);
            }
            else {
                memory_label.set_opacity (0.2);
            }
        }
        public void get_answer_evaluate () {
            var sci_calc = new ScientificCalculator ();
            string result = "";
            Settings settings = Settings.get_default ();
            if (!this.sci_view.window.history_manager.is_empty (EvaluationResult.ResultSource.SCIF)) {
                string last_answer = this.sci_view.window.history_manager.get_last_evaluation_result (EvaluationResult.ResultSource.SCIF).result;
                result = sci_calc.get_result (input_entry.get_text ().replace ("ans", last_answer), angle_mode, settings.decimal_places);
            }
            else {
                result = sci_calc.get_result (input_entry.get_text (), angle_mode, settings.decimal_places);
            }
            answer_label.set_text (Utils.format_result (result));
            settings.sci_input_text = input_entry.get_text ();
            settings.sci_output_text = answer_label.get_text ();
            if (result == "E") {
                shake ();
            }
            else {
                this.sci_view.window.history_manager.append_from_strings (EvaluationResult.ResultSource.SCIF, input_entry.get_text (), result.replace (Utils.get_local_separator_symbol (), ""), angle_mode, null, 0, 0, 0);
            }
        }

        private void shake () {
            get_style_context ().add_class ("pebbles_shake");
            Timeout.add (450, () => {
                get_style_context ().remove_class ("pebbles_shake");
                return false;
            });
        }
        // Just eye-candy
        public void display_off () {
            answer_label.set_opacity (0.1);
            input_entry.set_opacity (0.1);
            lcd_status_bar.set_opacity (0.1);
        }

        public void display_on () {
            answer_label.set_opacity (1);
            input_entry.set_opacity (1);
            lcd_status_bar.set_opacity (1);
        }

        public void send_backspace () {
            input_entry.backspace ();
            if (input_entry.get_text () == "") {
                input_entry.set_text ("0");
                input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
            }
        }

        public void insert_text (string text) {
            if (input_entry.get_text () == "0") {
                input_entry.set_text ("");
            }
            input_entry.grab_focus_without_selecting ();
            input_entry.insert_at_cursor (text);
        }

        public void set_evaluation (EvaluationResult result) {
            input_entry.set_text (result.problem_expression);
            input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);

            answer_label.set_text (result.result);
        }

        public void write_answer_to_clipboard () {
            Gdk.Display display = this.get_display ();
            Gtk.Clipboard clipboard = Gtk.Clipboard.get_for_display (display, Gdk.SELECTION_CLIPBOARD);
            string last_answer = answer_label.get_text().replace(Utils.get_local_separator_symbol(), "");
            clipboard.set_text (last_answer, -1);
        }
    }
}
