namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/statistics_view.ui")]
    public class StatisticsView : View {
        private StatOp op = SUM;
        [GtkChild]
        private unowned Adw.NavigationSplitView stat_nav_split_view;
        [GtkChild]
        private unowned StatisticsDisplay display;

        [GtkChild]
        private unowned Gtk.ToggleButton shift_button;
        [GtkChild]
        private unowned Button last_answer_button;
        [GtkChild]
        private unowned Button memory_plus_button;
        [GtkChild]
        private unowned Button memory_minus_button;
        [GtkChild]
        private unowned Button memory_recall_button;
        [GtkChild]
        private unowned Button memory_clear_button;
        [GtkChild]
        private unowned Button go_left;
        [GtkChild]
        private unowned Button go_right;

        public bool collapsed { get; set; }

        protected List<List<string>> table;

        public signal void on_evaluate (StatOp op, Json.Object options);
        public signal string on_memory_recall (bool global);
        public signal void on_memory_clear (bool global);

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

            var csv_files_filter = new Gtk.FileFilter () {
                name = _("Comma Separated Value files"),
            };
            csv_files_filter.add_mime_type ("text/csv");

            var filter_model = new ListStore (typeof (Gtk.FileFilter));
            filter_model.append (all_files_filter);
            filter_model.append (csv_files_filter);

            var file_dialog = new Gtk.FileDialog () {
                accept_label = _("Import"),
                default_filter = csv_files_filter,
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

        public void save_csv (MainWindow main_window) {
            var all_files_filter = new Gtk.FileFilter () {
                name = _("All files"),
            };
            all_files_filter.add_pattern ("*");

            var csv_files_filter = new Gtk.FileFilter () {
                name = _("Comma Separated Value files"),
            };
            csv_files_filter.add_mime_type ("text/csv");

            var filter_model = new ListStore (typeof (Gtk.FileFilter));
            filter_model.append (all_files_filter);
            filter_model.append (csv_files_filter);

            var file_dialog = new Gtk.FileDialog () {
                accept_label = _("Export"),
                default_filter = csv_files_filter,
                filters = filter_model,
                modal = true,
                title = _("Export CSV files")
            };

            file_dialog.save.begin (main_window, null, (obj, result) => {
                try {
                    var file = file_dialog.save.end (result);
                    if (file != null) {
                        string? file_path = file.get_path ();
                        if (file_path != null) {
                            main_window.on_stat_export (file_path);  // Call Python to save CSV
                            main_window.send_toast (_("Exported CSV file!"));
                        }
                    }
                } catch (Error e) {
                    print ("Failed to save file: %s\n", e.message);
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

        public void send_shift_modifier (bool shifted) {
            shift_button.active = shifted;
            on_shift ();
        }

        public void key_navigate () {
            if (shift_button.active)
                display.navigate (LEFT);
            else
                display.navigate (RIGHT);
        }

        public void key_extreme_navigate (bool left = false) {
            if (left)
                display.navigate (FIRST);
            else
                display.navigate (LAST);
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
            if (shift_button.active)
                display.navigate (FIRST);
            else
                display.navigate (LEFT);
        }

        [GtkCallback]
        protected void navigate_right () {
            if (shift_button.active)
                display.navigate (LAST);
            else
                display.navigate (RIGHT);
        }

        [GtkCallback]
        protected void navigate_up () {
            display.navigate (UP);
        }

        [GtkCallback]
        protected void navigate_down () {
            display.navigate (DOWN);
        }

        [GtkCallback]
        protected void perform_op (Gtk.Button btn) {
            StatOp op;
            print ("%s\n", stat_op_to_exp (Pebbles.StatOp.SHAPE));
            if (StatOp.try_parse_name (btn.name.up (), out op)) {
                this.op = op;
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

            this.op = op;
            evaluate_op (op);
            return Gdk.EVENT_STOP;
        }

        private void evaluate_op (StatOp op, int memory_op = 0) {
            var object = new Json.Object ();
            object.set_int_member ("seriesIndex", display.series_index);
            object.set_int_member ("memoryOp", memory_op);
            display.set_op (op);
            on_evaluate (op, object);
        }

        public void show_history (HistoryModel[] history) {
            display.show_history (history);
        }

        public void set_memory_present (bool present) {
            display.set_memory_present (present);
        }

        public void set_global_memory_present (bool present) {
            display.set_global_memory_present (present);
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

        [GtkCallback]
        protected void on_shift () {
            memory_plus_button.label_text = shift_button.active ? "SM+" : "M+";
            memory_plus_button.tooltip_desc = shift_button.active
            ? _("Add it to the value in Shared Memory") : _("Add it to the value in Memory");
            memory_minus_button.label_text = shift_button.active ? "SM−" : "M−";
            memory_minus_button.tooltip_desc = shift_button.active
            ? _("Subtract it from the value in Shared Memory")
            : _("Subtract it from the value in Memory");
            memory_recall_button.label_text = shift_button.active ? "SMR" : "MR";
            memory_recall_button.tooltip_desc = shift_button.active
            ? _("Recall value from Shared Memory") : _("Recall value from Memory");
            memory_clear_button.label_text = shift_button.active ? "SMC" : "MC";
            memory_clear_button.tooltip_desc = shift_button.active ? _("Shared Memory Clear") : _("Memory Clear");
            last_answer_button.label_text = shift_button.active ? "GAns" : "Ans";
            last_answer_button.tooltip_desc = shift_button.active
            ? _("Insert global last answer") : _("Insert last answer");

            go_left.icon_name = shift_button.active ? "go-first-symbolic" : "go-previous-symbolic";
            go_left.key = shift_button.active ? "Home" : "<Shift>Tab";
            go_left.accel_markup = shift_button.active ? "Home" : "<Shift>Tab";
            go_left.tooltip_desc = shift_button.active ? _("Navigate to the beginning") : _("Navigate Left");
            go_right.icon_name = shift_button.active ? "go-last-symbolic" : "go-next-symbolic";
            go_right.key = shift_button.active ? "End" : "Tab";
            go_right.accel_markup = shift_button.active ? "End" : "Tab";
            go_right.tooltip_desc = shift_button.active ? _("Navigate to the end") : _("Navigate Right");
        }

        [GtkCallback]
        protected void on_expand_fx () {
            stat_nav_split_view.show_content= true;
        }

        [GtkCallback]
        protected void on_collapse_fx () {
            stat_nav_split_view.show_content = false;
        }

        [GtkCallback]
        protected void on_all_clear () {
            evaluate_op (StatOp.CLEAR_DATASET);
        }

        [GtkCallback]
        protected void backspace () {
            display.backspace ();
        }

        [GtkCallback]
        protected void on_series_clear () {
            evaluate_op (StatOp.CLEAR_SERIES);
        }

        [GtkCallback]
        public void on_click_memory_add () {
            evaluate_op (this.op, shift_button.active ? MemAppendOp.ADD_GLOBAL : MemAppendOp.ADD);
        }

        [GtkCallback]
        public void on_click_memory_subtract () {
            evaluate_op (this.op, shift_button.active ? MemAppendOp.SUBTRACT_GLOBAL : MemAppendOp.SUBTRACT);
        }

        [GtkCallback]
        public void on_click_memory_recall () {
            var text = on_memory_recall (shift_button.active);
            display.write (text);
        }

        [GtkCallback]
        public void on_click_memory_clear () {
            on_memory_clear (shift_button.active);
        }

        [GtkCallback]
        public void on_click_last_ans () {
            var window = (MainWindow) get_ancestor (typeof (MainWindow));
            var result = window.on_get_last_result (shift_button.active ? Context.GLOBAL : Context.STATISTICS);
            display.write (result);
        }

        public override void focus_main () {

        }
    }
}
