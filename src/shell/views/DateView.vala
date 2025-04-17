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
                do_calculations ();
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
        private unowned Gtk.Calendar main_calendar;


        private Granite.DatePicker datepicker_diff_from;
        private Granite.DatePicker datepicker_diff_to;
        private Granite.DatePicker datepicker_starting_from;

        protected Gtk.Adjustment day_adjustment { get; set; }
        protected Gtk.Adjustment month_adjustment { get; set; }
        protected Gtk.Adjustment year_adjustment { get; set; }

        private Pebbles.Settings settings;

        construct {
            datepicker_diff_from = new Granite.DatePicker ();
            date_dur_grid.attach (datepicker_diff_from, 0, 1);
            datepicker_diff_from.changed.connect (() => {
                do_calculations ();
            });

            datepicker_diff_to = new Granite.DatePicker ();
            date_dur_grid.attach (datepicker_diff_to, 0, 3);
            datepicker_diff_to.changed.connect (() => {
                do_calculations ();
            });

            datepicker_starting_from = new Granite.DatePicker ();
            date_add_grid.attach (datepicker_starting_from, 0, 1);

            day_adjustment = new Gtk.Adjustment (0, 0, 10000, 1, 30, 0);
            month_adjustment = new Gtk.Adjustment (0, 0, 10000, 1, 12, 0);
            year_adjustment = new Gtk.Adjustment (0, 0, 1000, 1, 4, 0);
        }

        private void do_calculations () {
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

        private DateFormatted format (DateTime start_date_time, DateTime end_date_time) {
            DateFormatted date_formatted = new DateFormatted ();
            Date start_date = Date ();
            Date end_date = Date ();
            start_date.set_dmy ( (DateDay)start_date_time.get_day_of_month (), start_date_time.get_month (), (DateYear)start_date_time.get_year ());
            end_date.set_dmy ( (DateDay)end_date_time.get_day_of_month (), end_date_time.get_month (), (DateYear)end_date_time.get_year ());

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
