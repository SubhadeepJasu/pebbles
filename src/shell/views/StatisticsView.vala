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

        public signal void on_evaluate (StatOp op, Json.Object options);

        construct {
            display.activate_op.connect (activate_keyboard_shortcut);
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
                on_evaluate (StatOp.LOAD_DATASET, object);
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
            StatOp op;
            print ("%s\n", stat_op_to_exp (Pebbles.StatOp.SHAPE));
            if (StatOp.try_parse_name (btn.name.up (), out op)) {
                evaluate_op (op);
            }
        }

        private bool activate_keyboard_shortcut (string key) {
            var op = StatOp.SHAPE;
            switch (key) {
                case "a":
                case "A":
                    display.add_cell ();
                    return Gdk.EVENT_STOP;
                case "n":
                case "N":
                    op = SHAPE;
                    break;
                case "o":
                case "O":
                    op = MODE;
                    break;
                case "e":
                case "E":
                    op = MEDIAN;
                    break;
                case "s":
                case "S":
                    op = SUM;
                    break;
                case "q":
                case "Q":
                    op = SUM_SQUARED;
                    break;
                case "v":
                case "V":
                    op = SAMPLE_VAR;
                    break;
                case "m":
                case "M":
                    op = MEAN;
                    break;
                case "x":
                case "X":
                    op = MEAN_SQUARED;
                    break;
                case "d":
                case "D":
                    op = SAMPLE_SD;
                    break;
                case "g":
                case "G":
                    op = GEOMETRIC_MEAN;
                    break;
                case "p":
                case "P":
                    op = POPULATION_VAR;
                    break;
                case "l":
                case "L":
                    op = POPULATION_SD;
                    break;
                default:
                    return Gdk.EVENT_PROPAGATE;
            }

            evaluate_op (op);
            return Gdk.EVENT_STOP;
        }

        private void evaluate_op (StatOp op) {
            var object = new Json.Object ();
            object.set_int_member ("seriesIndex", display.series_index);
            display.set_op (op);
            on_evaluate (op, object);
        }

        public void show_history (HistoryModel[] history) {
            display.show_history (history);
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
