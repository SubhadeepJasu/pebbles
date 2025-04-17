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

        construct {
            datepicker_diff_from = new Granite.DatePicker ();
            date_dur_grid.attach (datepicker_diff_from, 0, 1);

            datepicker_diff_to = new Granite.DatePicker ();
            date_dur_grid.attach (datepicker_diff_to, 0, 3);

            datepicker_starting_from = new Granite.DatePicker ();
            date_add_grid.attach (datepicker_starting_from, 0, 1);

            day_adjustment = new Gtk.Adjustment (0, 0, 10000, 1, 30, 0);
            month_adjustment = new Gtk.Adjustment (0, 0, 10000, 1, 12, 0);
            year_adjustment = new Gtk.Adjustment (0, 0, 1000, 1, 4, 0);
        }
    }
}
