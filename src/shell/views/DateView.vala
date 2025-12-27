namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/date_view.ui")]
    public class DateView : View {
        private string _selected_view;
        public string selected_view {
            get {
                return _selected_view;
            }
            set {
                _selected_view = value;
                var window = (MainWindow) get_ancestor (typeof (MainWindow));
                if (window != null) {
                    window.date_header_box_stack.visible_child_name = value;
                }
            }
        }

        private bool _diff_mode_dur;
        public bool diff_mode_dur {
            get {
                return _diff_mode_dur;
            }

            set {
                _diff_mode_dur = value;
                find_difference ();
            }
        }

        private bool _date_find_mode;
        public bool date_find_mode {
            get {
                return _date_find_mode;
            }

            set {
                _date_find_mode = value;
                find_date ();
            }
        }


        [GtkChild]
        private unowned Gtk.Grid date_dur_grid;
        [GtkChild]
        private unowned Gtk.Grid date_add_grid;
        [GtkChild]
        private unowned Gtk.Label date_diff_label;
        [GtkChild]
        private unowned Gtk.Label days_diff_label;
        [GtkChild]
        private unowned Gtk.Label week_day_label;
        [GtkChild]
        private unowned Gtk.Label date_dmy_label;
        [GtkChild]
        private unowned Gtk.Calendar main_calendar;


        private Granite.DatePicker datepicker_diff_from;
        private Granite.DatePicker datepicker_diff_to;
        private Granite.DatePicker datepicker_starting_from;

        protected Gtk.Adjustment day_adjustment { get; set; }
        protected Gtk.Adjustment month_adjustment { get; set; }
        protected Gtk.Adjustment year_adjustment { get; set; }

        private Pebbles.Settings settings;

        construct {
            settings = Settings.get_default ();
            datepicker_diff_from = new Granite.DatePicker ();
            datepicker_diff_from.date = new DateTime.now_local ();
            date_dur_grid.attach (datepicker_diff_from, 0, 1);
            datepicker_diff_from.changed.connect (() => {
                find_difference ();
                settings.date_diff_from = datepicker_diff_from.date.format_iso8601 ();
            });

            datepicker_diff_to = new Granite.DatePicker ();
            datepicker_diff_to.date = new DateTime.now_local ();
            date_dur_grid.attach (datepicker_diff_to, 0, 3);
            datepicker_diff_to.changed.connect (() => {
                find_difference ();
                settings.date_diff_to = datepicker_diff_to.date.format_iso8601 ();
            });

            datepicker_starting_from = new Granite.DatePicker ();
            datepicker_starting_from.date = new DateTime.now_local ();
            datepicker_starting_from.changed.connect (() => {
                find_date ();
            });
            date_add_grid.attach (datepicker_starting_from, 0, 1);

            if (settings.load_last_session) {
                day_adjustment = new Gtk.Adjustment (settings.date_add_days, 0, 10000, 1, 30, 0);
                month_adjustment = new Gtk.Adjustment (settings.date_add_months, 0, 10000, 1, 12, 0);
                year_adjustment = new Gtk.Adjustment (settings.date_add_years, 0, 1000, 1, 4, 0);
            } else {
                day_adjustment = new Gtk.Adjustment (0, 0, 10000, 1, 30, 0);
                month_adjustment = new Gtk.Adjustment (0, 0, 10000, 1, 12, 0);
                year_adjustment = new Gtk.Adjustment (0, 0, 1000, 1, 4, 0);
            }

            Idle.add_once (load_settings);
        }

        private void load_settings () {
            if (settings.date_diff_from != "") {
                datepicker_diff_from.date = new DateTime.from_iso8601 (settings.date_diff_from, null);
            }

            if (settings.date_diff_to != "") {
                datepicker_diff_to.date = new DateTime.from_iso8601 (settings.date_diff_to, null);
            }

            if (settings.date_starting_from != "") {
                datepicker_starting_from.date = new DateTime.from_iso8601 (settings.date_starting_from, null);
            }
        }

        private void find_difference () {
            var datetime_diff_from = datepicker_diff_from.date;
            var datetime_diff_to = datepicker_diff_to.date;

            int order = datetime_diff_from.compare (datetime_diff_to);
            if (order >= 1) {
                var temp = datetime_diff_from;
                datetime_diff_from = datetime_diff_to;
                datetime_diff_to = temp;
            }

            var window = (MainWindow) get_ancestor (typeof (MainWindow));

            if (diff_mode_dur) {
                datetime_diff_to = datetime_diff_to.add_days (1);
            }

            string result_days = window.on_process_date_difference (datetime_diff_from, datetime_diff_to);
            result_days += (result_days == "1") ? (" " + _("day")) : (" " + _("days"));
            days_diff_label.set_text (_("A total of %s").printf (result_days));

            DateFormatted formatted_date_difference = format (datetime_diff_from , datetime_diff_to);
            string res_day = formatted_date_difference.day.to_string ();
            string res_wek = formatted_date_difference.week.to_string ();
            string res_mon = formatted_date_difference.month.to_string ();
            string res_yar = formatted_date_difference.year.to_string ();

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

        [GtkCallback]
        protected void find_date () {
            var given_date = datepicker_starting_from.date;
            if (!date_find_mode) {
                given_date = given_date.add_days ((int) day_adjustment.value);
                given_date = given_date.add_months ((int) month_adjustment.value);
                given_date = given_date.add_years ((int) year_adjustment.value);
            }
            else {
                given_date = given_date.add_days (0 - (int) day_adjustment.value);
                given_date = given_date.add_months (0 - (int) month_adjustment.value);
                given_date = given_date.add_years (0 - (int) year_adjustment.value);
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
            main_calendar.year = given_date.get_year ();
            main_calendar.month = given_date.get_month () - 1;
            main_calendar.day = given_date.get_day_of_month ();
            date_dmy_label.set_text (formatted_date);

            if (settings.load_last_session) {
                settings.date_add_days = (int) day_adjustment.value;
                settings.date_add_months = (int) month_adjustment.value;
                settings.date_add_years = (int) year_adjustment.value;
                settings.date_starting_from = datepicker_starting_from.date.format_iso8601 ();
            } else {
                settings.date_add_days = 0;
                settings.date_add_months = 0;
                settings.date_add_years = 0;
                settings.date_starting_from = "";
            }
        }

        private DateFormatted format (DateTime start_date_time, DateTime end_date_time) {
            DateFormatted date_formatted = new DateFormatted ();
            Date start_date = Date ();
            Date end_date = Date ();
            start_date.set_dmy (
                (DateDay)start_date_time.get_day_of_month (),
                start_date_time.get_month (),
                (DateYear)start_date_time.get_year ()
            );
            end_date.set_dmy (
                (DateDay)end_date_time.get_day_of_month (),
                end_date_time.get_month (),
                (DateYear)end_date_time.get_year ()
            );

            while (start_date.compare (end_date) <= 0) {
                start_date.add_years (1);
                date_formatted.year = date_formatted.year + 1;
            }
            start_date.subtract_years (1);
            date_formatted.year = date_formatted.year - 1;
            while (start_date.compare (end_date) <= 0) {
                start_date.add_months (1);
                date_formatted.month = date_formatted.month + 1;
            }
            start_date.subtract_months (1);
            date_formatted.month = date_formatted.month - 1;
            date_formatted.week = (int) ((start_date.days_between (end_date)) / 7);
            date_formatted.day = (start_date.days_between (end_date)) % 7;
            return date_formatted;
        }

        public override void focus_main () {
            if (selected_view == "date_diff_view") {
                datepicker_diff_from.grab_focus ();
            } else {
                datepicker_starting_from.grab_focus ();
            }
        }

        public override void copy () {
        }
    }

    private class DateFormatted {
        public int day;
        public int week;
        public int month;
        public int year;

        public DateFormatted () {
            day = 0;
            week = 0;
            month = 0;
            year = 0;
        }
    }
}
