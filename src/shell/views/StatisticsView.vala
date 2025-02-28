namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/statistics_view.ui")]
    public class StatisticsView : View {
        [GtkChild]
        private unowned StatisticsDisplay display;

        private bool _collapsed;
        public bool collapsed {
            get {
                return _collapsed;
            }

            set construct {
                _collapsed = value;
                show_hide_fx_btn = !value;
            }
        }

        protected bool show_hide_fx_btn { get; set; }

        protected List<List<string>> table;

        public signal void on_evaluate (string op, Json.Object options);

        construct {
            display.changed.connect ((series, series_index, width, height) => {
                var object = new Json.Object ();
                var json_array = new Json.Array ();
                for (int i = 0; i < series.length; i++) {
                    json_array.add_double_element (series[i]);
                }

                object.set_array_member ("series", json_array);
                object.set_int_member ("seriesIndex", series_index);
                object.set_double_member ("plotWidth", width);
                object.set_double_member ("plotHeight", height);
                on_evaluate ("set", object);
            });
        }

        public void show_result (string res) {
            display.show_result (res);
        }

        public void plot (Gdk.Pixbuf? pixbuf, bool valid) {
            display.plot (pixbuf, valid);
        }

        public void import_csv_file (MainWindow main_window) {
            var all_files_filter = new Gtk.FileFilter () {
                name = _("All files"),
            };
            all_files_filter.add_pattern ("*");

            var music_files_filter = new Gtk.FileFilter () {
                name = _("Comma Separated Value files"),
            };
            music_files_filter.add_mime_type ("text/csv");

            var filter_model = new ListStore (typeof (Gtk.FileFilter));
            filter_model.append (all_files_filter);
            filter_model.append (music_files_filter);

            var file_dialog = new Gtk.FileDialog () {
                accept_label = _("Import"),
                default_filter = music_files_filter,
                filters = filter_model,
                modal = true,
                title = _("Import CSV files")
            };

            file_dialog.open.begin (main_window, null, (obj, res) => {
                try {
                    File? file = file_dialog.open.end (res);
                    read_file_async.begin (file);
                } catch (Error e) {

                }
            });
        }

        private async void read_file_async (File file) {
            try {

                var stream = yield file.read_async ();
                var data_stream = new DataInputStream (stream);

                var object = new Json.Object ();
                object.set_string_member ("csv", data_stream.read_upto (null, 0, null));
                on_evaluate ("set-all", object);
            } catch (Error e) {

            }
        }

        public void refresh (int series_length = -1) {
            display.refresh_all_cells (series_length);
        }

        public void send_shift_modifier (bool on) {
            display.send_shift_modifier (on);
        }

        public void key_navigate () {
            display.key_navigate ();
        }

        [GtkCallback]
        protected void add_cell () {
            display.add_cell ();
        }

        [GtkCallback]
        protected void switch_plot () {
            display.switch_plot ();
        }

        [GtkCallback]
        protected void navigate_left () {
            display.navigate (0);
        }

        [GtkCallback]
        protected void navigate_right () {
            display.navigate (1);
        }

        [GtkCallback]
        protected void navigate_up () {
            display.navigate (2);
        }

        [GtkCallback]
        protected void navigate_down () {
            display.navigate (3);
        }

        [GtkCallback]
        protected void perform_op (Gtk.Button btn) {
            var object = new Json.Object ();
            object.set_int_member ("seriesIndex", display.series_index);
            display.set_op (btn.name);
            on_evaluate (btn.name, object);
        }

        [GtkCallback]
        public void write_char (Gtk.Button btn) {
            display.write (btn.name);
        }

        [GtkCallback]
        protected void on_click_fraction_point () {
            display.write (_("."));
        }
        [GtkCallback]
        protected void on_click_negative () {
            display.write ("-");
        }
    }
}
