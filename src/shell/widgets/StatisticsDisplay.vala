namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/statistics_display.ui")]
    public class StatisticsDisplay : Display {
        public string add_cell_warning_text { get; construct; }
        private int _series_index = 0;
        public int series_index {
            get {
                return _series_index;
            }

            set {
                _series_index = value;
                series_label = _("Series %d").printf (value);
            }
        }

        public string series_label { get; private set; default = _("Series 0") ;}

        [GtkChild]
        private unowned Gtk.Box data_table;
        [GtkChild]
        private unowned Gtk.Label add_cell_warning;
        [GtkChild]
        private unowned Gtk.DrawingArea plot_area;

        private List<Gtk.Entry?> cells;
        private double plot_height;
        private unowned MainWindow main_window;
        private StatPlotType plot_type = BAR;
        private Gdk.Pixbuf figure;

        public signal void changed (double[] series, int series_index, double width, double height);

        construct {
            add_cell_warning_text = "▭+  " + _("Enter data by adding new cell");
            plot_area.set_draw_func (draw);

            add_tick_callback (() => {
                if (plot_height != plot_area.get_height ()) {
                    plot_height = plot_area.get_height ();
                    data_change_cb ();
                }
            });

            realize.connect (() => {
                main_window = get_ancestor (typeof (MainWindow)) as MainWindow;
            });
        }

        public void insert_cell (string? data = null) {
            if (cells == null) {
                cells = new List<Gtk.Entry?> ();
            }

            var cell = new Gtk.Entry () {
                has_frame = false,
                max_length = 20,
                input_purpose = NUMBER
            };
            cells.append (cell);
            cell.add_css_class ("data-table-cell");
            cell.changed.connect (data_change_cb);
            data_table.append (cell);
            if (data != null) {
                cell.text = data;
            }

            add_cell_warning.visible = false;
            Idle.add (() => {
                cell.grab_focus ();
                return false;
            });
        }

        private void data_change_cb () {
            uint n = cells.length ();
            var series = new double[n];
            for (uint i = 0; i < n; i++) {
                series[i] = double.parse (cells.nth_data (i).text);
            }

            changed (series, series_index, plot_area.get_width (), plot_area.get_height ());
        }

        public void plot () {
            plot_area.queue_draw ();
        }

        public void switch_plot () {
            int next_index = ((int) plot_type + 1) % ((int) StatPlotType.SCATTER + 1);
            plot_type = (StatPlotType) next_index;

            Idle.add_once (() => {
                plot ();
            });
        }

        private void draw (Gtk.DrawingArea area, Cairo.Context cr, int width, int height) {
            if (main_window != null) {
                var display = main_window.get_display ();
                var monitor = display.get_monitor_at_surface (main_window.get_surface ());
                double width_mm = monitor.get_width_mm ();
                int width_px = monitor.get_geometry ().width;
                figure = main_window.on_stat_plot (
                    width,
                    height,
                    plot_type,
                    width_px / (width_mm / 25.4)
                );

                if (figure != null) {
                    Gdk.cairo_set_source_pixbuf (
                        cr,
                        figure,
                        0,
                        0
                    );
                    cr.paint ();
                }
            }
        }
    }
}
