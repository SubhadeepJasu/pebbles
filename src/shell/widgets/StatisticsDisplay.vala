namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/statistics_display.ui")]
    public class StatisticsDisplay : Display {
        // Constants
        private const uint8 CELL_WIDTH = 86;

        // Bindings
        private int _series_index = 0;
        public int series_index {
            get {
                return _series_index;
            }

            private set {
                _series_index = value;
                series_label = _("Series %d").printf (value + 1);
            }
        }

        public int table_length { get; private set; }
        public int max_series_length { get; private set; }
        public string series_label { get; private set; default = _("Series 1") ;}
        public int query_offset { get; private set; }

        // Widget Children
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

        // Private members
        private List<StatCell?> cells;
        private double plot_height;
        private double plot_width;
        private double viewport_width;
        private unowned MainWindow main_window;
        private StatPlotType plot_type = BAR;
        private Gdk.Pixbuf? figure;
        private bool valid_figure = true;
        private unowned StatCell selected_cell = null;
        private bool updating = true;
        private uint resize_timeout_id = 0;
        private bool is_navigating = false;

        public signal void changed (double[] series, int series_index, double width, double height);

        construct {
            plot_area.set_draw_func (draw_figure);

            add_tick_callback (() => {
                if (plot_width != plot_area.get_width () || plot_height != plot_area.get_height ()) {
                    plot_width = plot_area.get_width ();
                    plot_height = plot_area.get_height ();

                    // Cancel previous timeout if it exists
                    if (resize_timeout_id != 0) {
                        GLib.Source.remove (resize_timeout_id);
                    }

                    resize_timeout_id = GLib.Timeout.add (300, () => { // 300ms delay
                        start_plot ();
                        resize_timeout_id = 0; // Reset ID after execution
                        return false; // Run only once
                    });
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

            viewport.hadjustment.value_changed.connect (() => {
                if (is_navigating) return;

                int new_offset = (int) Math.ceil (viewport.hadjustment.value / CELL_WIDTH);

                // Clamp within valid bounds
                new_offset = int.max (0, int.min (new_offset, max_series_length - (int) cells.length ()));

                if (new_offset != query_offset) {
                    query_offset = new_offset;
                    update_placeholders ();
                    refresh_all_cells ();
                }

                viewport.hadjustment.value = new_offset * CELL_WIDTH;
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
                    cell.data_changed.connect (set_cell_value);
                    cell.focus_in.connect (cell_focus_handler);
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

            if (selected_cell == null) {
                selected_cell = cells.nth_data (0);
                selected_cell.grab_focus_without_selecting ();
            }
        }

        public void clear_cells () {
        }

        public void navigate (int direction) {
            switch (direction) {
                case 0:
                    if (selected_cell.index > query_offset) {
                        var new_focus_index = selected_cell.index - 1;
                        foreach (var cell in cells) {
                            if (cell.index == new_focus_index) {
                                cell.grab_focus_without_selecting ();
                                return;
                            }
                        }
                    }
                    // If at the leftmost cell and there's room to scroll left
                    else if (query_offset > 0) {
                        query_offset--;
                        is_navigating = true;
                        update_placeholders ();
                        refresh_all_cells ();
                        navigate (1);
                        Timeout.add_once (50, () => {
                            Idle.add_once (() => {
                                navigate (0);
                                Timeout.add_once (200, () => {
                                    is_navigating = false;
                                });
                            });
                        });
                    }
                break;
                case 1:
                    uint next_index = selected_cell.index + 1;

                    if (next_index < query_offset + cells.length ()) {
                        // Move focus to the next cell in the visible range
                        foreach (var cell in cells) {
                            if (cell.index == next_index) {
                                cell.grab_focus_without_selecting ();
                                return;
                            }
                        }
                    } else {
                        // Shift right if at the end
                        if (query_offset + cells.length () <= max_series_length) {
                            query_offset++;  // Shift the viewport right
                            is_navigating = true;
                            update_placeholders ();
                            refresh_all_cells ();
                            navigate (0);
                            Timeout.add_once (50, () => {
                                Idle.add_once (() => {
                                    navigate (1);
                                    Timeout.add_once (200, () => {
                                        is_navigating = false;
                                    });
                                });
                            });
                        }
                    }
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

        public void refresh_all_cells () {
            var n = cells.length ();
            unowned StatCell? cell = null;
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
                plot_area.get_width (),
                plot_area.get_height (),
                plot_type,
                width_px / (width_mm / 25.4)
            );
        }

        public void plot (Gdk.Pixbuf? figure, bool valid) {
            this.figure = figure;
            valid_figure = valid;
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

        private void set_cell_value (double value, uint index, uint series_index) {
            max_series_length = main_window.on_stat_cell_update (value, (int) index, (int) series_index);
            update_placeholders ();
        }

        private void draw_figure (Gtk.DrawingArea area, Cairo.Context cr, int width, int height) {
            if (figure != null) {
                cr.set_operator (Cairo.Operator.SOURCE);
                Gdk.cairo_set_source_pixbuf (
                    cr,
                    figure,
                    0,
                    0
                );
                cr.paint ();
            } else if (!valid_figure) {
                // Draw a "No Symbol" (🛇)
                double radius = double.min (width, height) * 0.2;
                double cx = width / 2.0;
                double cy = height / 2.0;

                // Draw Circle
                cr.set_source_rgba (0.152941176, 0.156862745, 0.388235294, 0.8);
                cr.set_line_width (5.0);
                cr.arc (cx, cy, radius, 0, 2 * Math.PI);
                cr.stroke ();

                // Draw Slash
                cr.move_to (cx - radius * 0.7, cy - radius * 0.7);
                cr.line_to (cx + radius * 0.7, cy + radius * 0.7);
                cr.stroke ();

                cr.set_font_size (12);
                switch (plot_type) {
                    case PIE:
                        cr.move_to (8, height - 8);
                        cr.show_text (_("Cannot plot pie chart for this data"));
                        break;
                    case BAR:
                        cr.move_to (8, height - 8);
                        cr.show_text (_("Cannot plot bar chart for this data"));
                        break;
                    default:
                        cr.move_to (8, height - 8);
                        cr.show_text (_("Cannot plot anything for this data"));
                        break;
                }
            }
        }

        private void cell_focus_handler (StatCell cell) {
            selected_cell = cell;
        }

        private void update_placeholders () {
            int num_visible_cells = (int) Math.floor (viewport.get_width () / CELL_WIDTH);
            // Adjust placeholder sizes
            placeholder_l.width_request = int.max (query_offset * CELL_WIDTH, -1);
            placeholder_r.width_request = int.max ((max_series_length - query_offset - num_visible_cells) * CELL_WIDTH, -1);
        }
    }
}
