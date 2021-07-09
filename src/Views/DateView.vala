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
    public class DateView : Gtk.Grid {
        // Make Date Calculation Mode Switcher
        Granite.Widgets.ModeButton date_mode;
        
        // Make Date Difference View
        Gtk.Grid date_difference_view;
        Granite.Widgets.DatePicker datepicker_diff_from;
        DateTime datetime_diff_from;
        Granite.Widgets.DatePicker datepicker_diff_to;
        DateTime datetime_diff_to;
        Gtk.Label date_diff_label;
        Gtk.Label days_diff_label;
        
        // Make Add Date View
        Gtk.Grid date_add_view;
        Granite.Widgets.DatePicker datepicker_add_sub;
        Gtk.Label week_day_label;
        Gtk.Label date_dmy_label;
        Gtk.Label add_label;
        Gtk.Entry add_entry_day;
        Gtk.Entry add_entry_month;
        Gtk.Entry add_entry_year;
        Gtk.Calendar main_calendar;
        
        // Header Bar Controls
        Gtk.Stack date_mode_stack;
        Gtk.Switch diff_mode_switch;
        Gtk.Switch add_mode_switch;
        
        Gtk.Grid date_diff_grid;
        Gtk.Grid date_add_grid;

        Gtk.Label add_header;

        Pebbles.Settings settings;
        
        DateCalculator date_calculator_object;

        public Granite.Widgets.ModeButton diff_mode_button;
        public Granite.Widgets.ModeButton add_mode_button;
        
        public DateView (MainWindow window) {
            settings = Settings.get_default ();
            build_ui ();
            this.diff_mode_switch = window.diff_mode_switch;
            this.add_mode_switch = window.add_mode_switch;
            this.date_mode_stack = window.date_mode_stack;
            this.date_diff_grid = window.date_diff_grid;
            this.date_add_grid = window.date_add_grid;
            this.diff_mode_switch.state_set.connect ((event) => {
                do_calculations ();
                diff_mode_button.set_active (this.diff_mode_switch.active ? 1 : 0);
                return false;
            });
            this.diff_mode_button.mode_changed.connect (() => {
                do_calculations ();
                if (diff_mode_button.selected == 0) {
                    this.diff_mode_switch.set_active (false);
                } else {
                    this.diff_mode_switch.set_active (true);
                }
            });
            this.add_mode_switch.state_set.connect ((event) => {
                if (add_mode_switch.get_active ()) {
                    add_label.set_text (_("Subtract"));
                    add_mode_button.set_active (1);
                    if (add_header != null)
                        add_header.set_text (_("The Date was"));
                    find_date (true);
                }
                else {
                    add_label.set_text (_("Add"));
                    add_mode_button.set_active (0);
                    if (add_header != null)
                        add_header.set_text (_("The Date will be"));
                    find_date (false);
                }
                return false;
            });

            this.add_mode_button.mode_changed.connect (() => {
                if (add_mode_button.selected == 0) {
                    add_label.set_text (_("Add"));
                    add_mode_switch.set_active (false);
                    if (add_header != null)
                        add_header.set_text (_("The Date will be"));
                    find_date (false);
                } else {
                    add_label.set_text (_("Subtract"));
                    add_mode_switch.set_active (true);
                    if (add_header != null)
                        add_header.set_text (_("The Date was"));
                    find_date (true);
                }
            });
            load_date ();
        }
        
        private void build_ui () {
            // Make Date Mode Switcher ////////////////////////////////////////////////////
            date_mode = new Granite.Widgets.ModeButton ();
            date_mode.append_text (_("Find Difference"));
            date_mode.append_text (_("Infer Date"));
            date_mode.margin = 8;
            
            // Make Date Difference View
            // ---------------------------------------------------------------------------
            date_difference_view = new Gtk.Grid ();
            diff_mode_button = new Granite.Widgets.ModeButton ();
            diff_mode_button.append_text (_("AGE"));
            diff_mode_button.append_text (_("DUR"));
            diff_mode_button.set_active (0);
            var from_label = new Gtk.Label (_("From"));
            from_label.xalign = 0;
            from_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            datepicker_diff_from = new Granite.Widgets.DatePicker ();
            var to_label  = new Gtk.Label (_("To"));
            to_label.margin_top = 4;
            to_label.xalign = 0;
            to_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            datepicker_diff_to   = new Granite.Widgets.DatePicker ();
            date_difference_view.attach (diff_mode_button, 0, 0, 1, 1);
            date_difference_view.attach (from_label, 0, 1, 1, 1);
            date_difference_view.attach (datepicker_diff_from, 0, 2, 1, 1);
            date_difference_view.attach (to_label, 0, 3, 1, 1);
            date_difference_view.attach (datepicker_diff_to, 0, 4, 1, 1);
            
            var diff_header = new Gtk.Label (_("Difference"));
            diff_header.xalign = 0;
            diff_header.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            
            date_diff_label = new Gtk.Label (_("Hey, it's the same date") + "\n");
            date_diff_label.xalign = 0;
            date_diff_label.hexpand = true;
            date_diff_label.set_line_wrap (true);
            date_diff_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            days_diff_label = new Gtk.Label ("");
            days_diff_label.xalign = 0;
            days_diff_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            var diff_grid = new Gtk.Grid ();
            diff_grid.attach (diff_header,0, 0, 1, 1);
            diff_grid.attach (date_diff_label,0, 1, 1, 1);
            diff_grid.attach (days_diff_label,0, 2, 1, 1);
            
            
            var separator_diff = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            separator_diff.margin = 28;
            separator_diff.hexpand = true;
            
            date_difference_view.attach (separator_diff, 0, 5, 1, 1);
            date_difference_view.attach (diff_grid, 0, 6, 1, 1);
            
            date_difference_view.height_request = 200;
            date_difference_view.margin_start = 8;
            date_difference_view.margin_end = 8;
            date_difference_view.margin_bottom = 8;
            date_difference_view.column_spacing = 8;
            date_difference_view.row_spacing = 4;
            
            // Make Add Date View
            // ----------------------------------------------------------------------------
            date_add_view = new Gtk.Grid ();
            add_mode_button = new Granite.Widgets.ModeButton ();
            add_mode_button.append_text (_("ADD"));
            add_mode_button.append_text (_("SUB"));
            add_mode_button.set_active (0);
            var start_label = new Gtk.Label (_("Starting from"));
            start_label.xalign = 0;
            start_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            add_label = new Gtk.Label (_("Add"));
            add_label.xalign = 0;
            add_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            
            var date_input_grid = new Gtk.Grid ();
            
            add_entry_day   = new Gtk.Entry ();
            add_entry_day.placeholder_text = _("Day");
            add_entry_day.set_text (settings.date_day_entry);
            add_entry_day.max_length  = 3;
            add_entry_day.width_chars = 6;
            add_entry_day.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY,"view-more-symbolic");
            var day_popper = new BottomPopper (add_entry_day);
            add_entry_day.icon_release.connect (() => {
                day_popper.set_visible (true);
            });
            add_entry_day.set_input_purpose (Gtk.InputPurpose.NUMBER);
            add_entry_day.changed.connect (() => {
                find_date (add_mode_switch.get_active ());
                settings.date_day_entry = add_entry_day.get_text ();
            });
            
            add_entry_month = new Gtk.Entry ();
            add_entry_month.placeholder_text = _("Month");
            add_entry_month.set_text (settings.date_month_entry);
            add_entry_month.max_length  = 3;
            add_entry_month.width_chars = 6;
            add_entry_month.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY,"view-more-symbolic");
            var month_popper = new BottomPopper (add_entry_month);
            add_entry_month.icon_release.connect (() => {
                month_popper.set_visible (true);
            });
            add_entry_month.set_input_purpose (Gtk.InputPurpose.NUMBER);
            add_entry_month.changed.connect (() => {
                find_date (add_mode_switch.get_active ());
                settings.date_month_entry = add_entry_month.get_text ();
            });
            
            add_entry_year  = new Gtk.Entry ();
            add_entry_year.placeholder_text = _("Year");
            add_entry_year.set_text (settings.date_year_entry);
            add_entry_year.max_length  = 3;
            add_entry_year.width_chars = 6;
            add_entry_year.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY,"view-more-symbolic");
            var year_popper = new BottomPopper (add_entry_year);
            add_entry_year.icon_release.connect (() => {
                year_popper.set_visible (true);
            });
            add_entry_year.set_input_purpose (Gtk.InputPurpose.NUMBER);
            add_entry_year.changed.connect (() => {
                find_date (add_mode_switch.get_active ());
                settings.date_year_entry = add_entry_year.get_text ();
            });
            date_input_grid.attach (add_entry_day, 0, 0, 1, 1);
            date_input_grid.attach (add_entry_month, 1, 0, 1, 1);
            date_input_grid.attach (add_entry_year, 2, 0, 1, 1);
            date_input_grid.column_spacing = 4;
            date_input_grid.column_homogeneous = true;
            
            datepicker_add_sub  = new Granite.Widgets.DatePicker ();
            date_add_view.attach (add_mode_button, 0, 0, 1, 1);
            date_add_view.attach (start_label, 0, 1, 1, 1);
            date_add_view.attach (datepicker_add_sub, 0, 2, 1, 1);
            date_add_view.attach (add_label, 0, 3, 1, 1);
            date_add_view.attach (date_input_grid, 0, 4, 1, 1);
            
            
            date_add_view.height_request = 200;
            date_add_view.margin_start = 8;
            date_add_view.margin_end = 8;
            date_add_view.margin_bottom = 8;
            date_add_view.column_spacing = 8;
            date_add_view.row_spacing = 4;
            
            add_header = new Gtk.Label (_("The Date will be"));
            add_header.xalign = 0;
            add_header.valign = Gtk.Align.START;
            add_header.width_request = 160;
            add_header.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            
            week_day_label = new Gtk.Label (_("Set a duration"));
            //week_day_label.xalign = 0;
            week_day_label.valign = Gtk.Align.END;
            week_day_label.halign = Gtk.Align.START;
            week_day_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            date_dmy_label = new Gtk.Label (_("Days, months or year"));
            //date_dmy_label.xalign = 0;
            date_dmy_label.halign = Gtk.Align.START;
            date_dmy_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            var add_grid = new Gtk.Grid ();
            add_grid.attach (add_header,0, 0, 1, 1);
            add_grid.attach (week_day_label,0, 1, 1, 1);
            add_grid.attach (date_dmy_label,0, 2, 1, 1);
            
            main_calendar = new Gtk.Calendar ();
            main_calendar.set_display_options (Gtk.CalendarDisplayOptions.NO_MONTH_CHANGE);
            main_calendar.get_style_context ().add_class ("pebbles-calendar-box");
            main_calendar.show_day_names = true;
            main_calendar.width_request = 210;
            main_calendar.hexpand = true;
            main_calendar.margin_top = 8;
            add_grid.attach (main_calendar, 0, 3, 1, 1);
            
            date_add_view.attach (add_grid, 0, 5, 1, 1);            
            
            var date_calc_holder = new Gtk.Stack ();
            date_calc_holder.add_named (date_difference_view, _("Difference Between Dates"));
            date_calc_holder.add_named (date_add_view, _("Add or Subtract Dates"));
            date_calc_holder.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
            
            // Add events to Mode Button
            date_mode.set_active (0);
            date_mode.mode_changed.connect (() => {
                if (date_mode.selected == 0) {
                    date_calc_holder.set_visible_child (date_difference_view);
                    date_mode_stack.set_visible_child (date_diff_grid);
                }
                else if (date_mode.selected == 1){
                    date_calc_holder.set_visible_child (date_add_view);
                    date_mode_stack.set_visible_child (date_add_grid);
                }
                //stdout.printf ("%d\n", date_mode.selected);
            });
            
            date_calculator_object = new DateCalculator();
            
            datepicker_diff_from.changed.connect (() => {
                do_calculations ();
                settings.date_diff_from = datepicker_diff_from.date.format ("%FT%T");
            });
            datepicker_diff_to.changed.connect (() => {
                do_calculations ();
                settings.date_diff_to = datepicker_diff_to.date.format ("%FT%T");
            });
            datepicker_add_sub.changed.connect (() => {
                find_date (add_mode_switch.get_active ());
                settings.date_add_sub = datepicker_add_sub.date.format ("%FT%T");
            });
            
            attach (date_mode, 0, 0, 2, 1);
            attach (date_calc_holder, 0, 1, 1, 1);
            row_spacing = 54;
            valign = Gtk.Align.CENTER;
            vexpand = true;
        }
        
        private void do_calculations () {
            datetime_diff_from = datepicker_diff_from.date;
            datetime_diff_to = datepicker_diff_to.date;

            int order = datetime_diff_from.compare (datetime_diff_to);
            if (order >= 1) {
                var temp = datetime_diff_from;
                datetime_diff_from = datetime_diff_to;
                datetime_diff_to = temp;
            }

            if (diff_mode_switch.get_active()) {
                datetime_diff_to = datetime_diff_to.add_days (1);
            }
            string result_days = date_calculator_object.date_difference( datetime_diff_from , datetime_diff_to );
            result_days += (result_days == "1") ? (" " + _("day")) : (" " + _("days"));
            days_diff_label.set_text (_("A total of %s").printf (result_days));
            
            DateFormatted formatted_date_difference = date_calculator_object.difference_formatter(datetime_diff_from , datetime_diff_to);
            string res_day = (formatted_date_difference.day).to_string ();
            string res_wek = (formatted_date_difference.week).to_string ();
            string res_mon = (formatted_date_difference.month).to_string ();
            string res_yar = (formatted_date_difference.year).to_string ();
            
            // Present the data with some LOVE
            string result_date = "";
            int part = 0;
            if (res_yar == "0" && res_mon == "0" && res_wek == "0" && res_day == "0") {
                result_date = _("Hey, it's the same date") + "\n";
                days_diff_label.set_text ("");
            } else {
                if (res_yar != "0") {
                    result_date += res_yar + " " + ((res_yar == "1") ? (_("year")) : (_("years")));
                    part++;
                }
                if (res_mon != "0") {
                    if (res_day == "0" && res_wek == "0" && part > 0)
                        result_date += (" " + _("and") + " ");
                    else if (part > 0)
                        result_date += ", ";
                        result_date += res_mon + " " + ((res_mon == "1") ? (_("month")) : (_("months")));
                    part++;
                }
                if (res_wek != "0") {
                    if (res_day == "0" && part > 0)
                        result_date += (" " + _("and") + " ");
                    else if (part > 0)
                        result_date += ", ";
                        result_date += res_wek + " " + ((res_wek == "1") ? (_("week")) : (_("weeks")));
                        part++;
                }
                if (res_day != "0") {
                    //  if (part > 2)
                    //      result_date += "\n";
                    if (part != 0)
                        result_date += " ";
                    if (part > 0)
                        result_date += (_("and") + " ");
                    else
                        days_diff_label.set_text ("");
                        result_date += res_day + " " + ((res_day == "1") ? (_("day")) : (_("days")));
                }
            }
            if (order >= 1) {
                days_diff_label.set_text (days_diff_label.get_text () + ", " + _("counting backwards"));
            }
            date_diff_label.set_text (result_date);
        }
        private void find_date (bool mode) {
            var given_date = datepicker_add_sub.date;
            if (!mode) {
                given_date = given_date.add_days (int.parse (add_entry_day.get_text ()));
                given_date = given_date.add_months (int.parse (add_entry_month.get_text ()));
                given_date = given_date.add_years (int.parse (add_entry_year.get_text ()));
            }
            else {
                given_date = given_date.add_days (0 - int.parse (add_entry_day.get_text ()));
                given_date = given_date.add_months (0 - int.parse (add_entry_month.get_text ()));
                given_date = given_date.add_years (0 - int.parse (add_entry_year.get_text ()));
            }
            string formatted_date = given_date.format ("%x");
            string[] week_day = {
                (_("Monday")),
                (_("Tuesday")),
                (_("Wednesday")),
                (_("Thursday")),
                (_("Friday")),
                (_("Saturday")),
                (_("Sunday"))
            };
            switch (given_date.get_day_of_week ()) {
                case 1:
                    week_day_label.set_text (week_day[0]);
                    formatted_date = formatted_date.replace (week_day[0] + " ", "");
                    break;
                case 2:
                    week_day_label.set_text (week_day[1]);
                    formatted_date = formatted_date.replace (week_day[1] + " ", "");
                    break;
                case 3:
                    week_day_label.set_text (week_day[2]);
                    formatted_date = formatted_date.replace (week_day[2] + " ", "");
                    break;
                case 4:
                    week_day_label.set_text (week_day[3]);
                    formatted_date = formatted_date.replace (week_day[3] + " ", "");
                    break;
                case 5:
                    week_day_label.set_text (week_day[4]);
                    formatted_date = formatted_date.replace (week_day[4] + " ", "");
                    break;
                case 6:
                    week_day_label.set_text (week_day[5]);
                    formatted_date = formatted_date.replace (week_day[5] + " ", "");
                    break;
                case 7:
                    week_day_label.set_text (week_day[6]);
                    formatted_date = formatted_date.replace (week_day[6] + " ", "");
                    break;
                default:
                    week_day_label.set_text ("");
                    break;
            }
            main_calendar.select_month (given_date.get_month () - 1, given_date.get_year ());
            main_calendar.select_day (given_date.get_day_of_month ());
            date_dmy_label.set_text (formatted_date);
        }

        private DateTime get_date_from_string (string date_string) {
            DateTime date;
            if (date_string != "") {
                date = new DateTime.from_iso8601 (date_string, new TimeZone.local ());
            } else {
                date = new DateTime.now_local ();
            }
            
            return date;
        }

        private void load_date () {
            datepicker_diff_from.date = get_date_from_string (settings.date_diff_from);
            datepicker_diff_to.date = get_date_from_string (settings.date_diff_to);
            datepicker_add_sub.date = get_date_from_string (settings.date_add_sub);
        }
    }
}
