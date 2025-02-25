namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/statistics_display.ui")]
    public class StatisticsDisplay : Display {
        private const uint8 CELL_WIDTH = 72;

        private int _series_index = 0;
        public int series_index {
            get {
                return _series_index;
            }

            private set {
                _series_index = value;
                series_label = _("Series %d").printf (value);
            }
        }

        public int table_length { get; private set; }
        public int max_series_length { get; private set; }
        public string series_label { get; private set; default = _("Series 0") ;}
        public int query_offset { get; private set; }

        [GtkChild]
        private unowned Gtk.ScrolledWindow viewport;
        [GtkChild]
        private unowned Gtk.Box cell_box;
        [GtkChild]
        private unowned Gtk.Box placeholder_l;
        [GtkChild]
        private unowned Gtk.Box placeholder_r;
        [GtkChild]
        private unowned Gtk.DrawingArea plot_area;

        private List<StatCell?> cells;
        private double plot_height;
        private double plot_width;
        private double viewport_width;
        private unowned MainWindow main_window;
        private StatPlotType plot_type = BAR;
        private Gdk.Pixbuf figure;
        private unowned Gtk.Entry selected_cell = null;
        private bool updating = true;

        public signal void changed (double[] series, int series_index, double width, double height);

        construct {
            plot_area.set_draw_func (draw_figure);

            add_tick_callback (() => {
                if (plot_width != plot_area.get_width () || plot_height != plot_area.get_height ()) {
                    plot_width = plot_area.get_width ();
                    plot_height = plot_area.get_height ();

                    start_plot ();
                }

                if (viewport_width != viewport.get_width ()) {
                    viewport_width = viewport.get_width ();

                    draw_cells ();
                }

                return updating;
            });

            realize.connect (() => {
                main_window = get_ancestor (typeof (MainWindow)) as MainWindow;
                Idle.add_once (() => {
                    draw_cells ();
                });
            });
        }

        ~StatisticsDisplay () {
            updating = false;
        }

        private void draw_cells () {
            if (viewport == null || cell_box == null) {
                return;
            }

            uint num_visible_cells = (uint) Math.floor (viewport_width / CELL_WIDTH);
            uint current_cells = cells.length ();

            if (current_cells < num_visible_cells) {
                // Add the missing cells when more can fit
                for (uint i = current_cells; i < num_visible_cells; i++) {
                    uint index = query_offset + i; // Adjust index based on query_offset
                    var cell = new StatCell (index, series_index) {
                        width_request = CELL_WIDTH
                    };
                    cell_box.append (cell);
                    cells.append (cell);
                    cell.refresh ();
                }
            } else if (current_cells > num_visible_cells) {
                // Remove extra cells that are outside the visible area
                for (uint i = num_visible_cells; i < current_cells; i++) {
                    var last_child = (StatCell?) cell_box.get_last_child ();
                    if (last_child != null) {
                        cell_box.remove (last_child);
                        cells.remove (last_child);
                    }
                }
            }
        }

        public void clear_cells () {
        }

        public void navigate (int direction) {
            switch (direction) {
                case 0:
                break;
                case 1:

                break;
                case 2:
                    if (series_index > 0) {
                        series_index = series_index - 1;
                        refresh_all_cells ();
                    }
                break;
                case 3:
                    series_index = series_index + 1;
                    refresh_all_cells ();
                break;
            }
        }

        private void refresh_all_cells () {
            var n = cells.length ();
            unowned StatCell? cell;
            for (uint i = 0; i < n; i++) {
                cell = cells.nth_data (i);
                cell.index = query_offset + i;
                cell.series_index = series_index;
                cell.refresh ();
            }
        }

        public void start_plot () {
            var display = main_window.get_display ();
            var monitor = display.get_monitor_at_surface (main_window.get_surface ());
            double width_mm = monitor.get_width_mm ();
            int width_px = monitor.get_geometry ().width;
            main_window.on_stat_plot (
                plot_width,
                plot_height,
                plot_type,
                width_px / (width_mm / 25.4)
            );
        }

        public void plot (Gdk.Pixbuf figure) {
            this.figure = figure;
            Idle.add_once (() => {
                plot_area.queue_draw ();
            });
        }

        public void switch_plot () {
            int next_index = ((int) plot_type + 1) % ((int) StatPlotType.SCATTER + 1);
            plot_type = (StatPlotType) next_index;

            Idle.add_once (() => {
                start_plot ();
            });
        }

        private void draw_figure (Gtk.DrawingArea area, Cairo.Context cr, int width, int height) {
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
