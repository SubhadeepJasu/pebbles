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
        private unowned Gtk.Label main_label;
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


        // Status Bar
        [GtkChild]
        private unowned Gtk.Label result_type_label_g;
        [GtkChild]
        private unowned Gtk.Label result_type_label_m;
        [GtkChild]
        private unowned Gtk.Label result_type_label_edia;
        [GtkChild]
        private unowned Gtk.Label result_type_label_n;
        [GtkChild]
        private unowned Gtk.Label result_type_label_mode;
        [GtkChild]
        private unowned Gtk.Label result_type_label_summation;
        [GtkChild]
        private unowned Gtk.Label result_type_label_x_bar;
        [GtkChild]
        private unowned Gtk.Label result_type_label_x_sqr;
        [GtkChild]
        private unowned Gtk.Label result_type_label_sigma;
        [GtkChild]
        private unowned Gtk.Label result_type_label_sig_sqr;
        [GtkChild]
        private unowned Gtk.Label result_type_label_sv;
        [GtkChild]
        private unowned Gtk.Label result_type_label_sd;
        [GtkChild]
        private unowned Gtk.Label result_type_label_trend;

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
        private bool shift_on = false;

        public signal void changed (double[] series, int series_index, double width, double height);
        public signal bool activate_op (string op);

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
                main_window.on_key_down.connect ((mode, keyval) => {
                    if (keyval == Gdk.Key.Page_Up || keyval == Gdk.Key.Up) {
                        navigate (2);
                    } else if (keyval == Gdk.Key.Page_Down || keyval == Gdk.Key.Return || keyval == Gdk.Key.Down) {
                        navigate (3);
                    }

                    return Gdk.EVENT_STOP;
                });
            });

            viewport.hadjustment.value_changed.connect (() => {
                if (is_navigating) return;

                int new_offset = (int) Math.ceil (viewport.hadjustment.value / CELL_WIDTH);

                // Clamp within valid bounds
                new_offset = int.max (0, int.min (new_offset, max_series_length - (int) cells.length ()));

                if (new_offset != query_offset) {
                    query_offset = new_offset;
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
                    cell.get_delegate ().insert_text.connect (text_input_handler);
                    cell.refresh ();
                }
            } else if (current_cells > num_visible_cells) {
                // Remove extra cells that are outside the visible area
                bool selected_cell_removed = false;
                for (uint i = num_visible_cells; i < current_cells; i++) {
                    var last_child = (StatCell?) cell_box.get_last_child ();
                    if (last_child != null) {
                        if (last_child.has_focus) {
                            selected_cell_removed = true;
                        }

                        cell_box.remove (last_child);
                        cells.remove (last_child);
                        last_child.get_delegate ().insert_text.disconnect (text_input_handler);
                    }
                }

                if (selected_cell_removed) {
                    selected_cell = cells.nth_data (cells.length () - 1);
                    focus_cell (selected_cell);
                }
            }

            if (selected_cell == null) {
                selected_cell = cells.nth_data (0);
                focus_cell (selected_cell, true);
            }
        }

        private void text_input_handler (Gtk.Editable ed, string text, int n, ref int _) {
            if (n == 1 && activate_op (text)) {
                Signal.stop_emission_by_name (ed, "insert_text");
            }
        }

        public void send_shift_modifier (bool on) {
            shift_on = on;
        }

        public void key_navigate () {
            navigate (shift_on ? 0 : 1);
        }

        public void navigate (int direction) {
            switch (direction) {
                case 0:
                    if (selected_cell.index > query_offset) {
                        var new_focus_index = selected_cell.index - 1;
                        foreach (var cell in cells) {
                            if (cell.index == new_focus_index) {
                                focus_cell (cell);
                                return;
                            }
                        }
                    }
                    // If at the leftmost cell and there's room to scroll left
                    else if (query_offset > 0) {
                        query_offset--;
                        is_navigating = true;
                        refresh_all_cells ();
                        navigate (1);
                        Timeout.add_once (50, () => {
                            Idle.add_once (() => {
                                navigate (0);
                                Timeout.add_once (250, () => {
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
                                focus_cell (cell);
                                return;
                            }
                        }
                    } else {
                        // Shift right if at the end
                        if (query_offset + cells.length () <= max_series_length) {
                            query_offset++;  // Shift the viewport right
                            is_navigating = true;
                            refresh_all_cells ();
                            navigate (0);
                            Timeout.add_once (50, () => {
                                Idle.add_once (() => {
                                    navigate (1);
                                    Timeout.add_once (250, () => {
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

                    Idle.add_once (() => {
                        focus_cell (selected_cell);
                    });
                break;
                case 3:
                    series_index = series_index + 1;
                    refresh_all_cells ();
                    Idle.add_once (() => {
                        focus_cell (selected_cell);
                    });
                break;
            }
        }

        public void add_cell () {
            var new_offset = max_series_length - (int) cells.length ();
            if (new_offset >= 0) {
                query_offset = new_offset;
                is_navigating = true;
                refresh_all_cells ();
                Timeout.add_once (50, () => {
                    Idle.add_once (() => {
                        focus_cell (cells.nth_data (cells.length () - 1));
                        Timeout.add_once (250, () => {
                            is_navigating = false;
                            Timeout.add_once (100, () => {
                                navigate (1);
                            });
                        });
                    });
                });
            } else {
                selected_cell = cells.nth_data (max_series_length);
                focus_cell (selected_cell);
            }
        }


        public void refresh_all_cells (int series_length = -1) {
            if (series_length >= 0) {
                max_series_length = series_length;
            }

            update_placeholders ();
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

        public void show_result (string result) {
            if (result != "E") {
                add_css_class ("fade");
                Timeout.add (100, () => {
                    main_label.set_text (result);
                    remove_css_class ("fade");
                    return false;
                });
            } else {
                main_label.set_text (_("Error"));
                add_css_class ("shake");
                Timeout.add (400, () => {
                    remove_css_class ("shake");
                    return false;
                });
            }
        }

        private void set_cell_value (double value, uint index, uint series_index) {
            max_series_length = main_window.on_stat_cell_update (value, (int) index, (int) series_index);
            update_placeholders ();
        }

        private void focus_cell (StatCell? cell, bool select = false) {
            if (select) {
                cell?.grab_focus ();
            } else {
                cell?.grab_focus_without_selecting ();
                cell?.set_position ((int) cell.text_length);
            }
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

        public void set_op (string op) {
            result_type_label_g.opacity = 0.2;
            result_type_label_m.opacity = 0.2;
            result_type_label_edia.opacity = 0.2;
            result_type_label_n.opacity = 0.2;
            result_type_label_mode.opacity = 0.2;
            result_type_label_summation.opacity = 0.2;
            result_type_label_x_bar.opacity = 0.2;
            result_type_label_x_sqr.opacity = 0.2;
            result_type_label_sigma.opacity = 0.2;
            result_type_label_sig_sqr.opacity = 0.2;
            result_type_label_sv.opacity = 0.2;
            result_type_label_sd.opacity = 0.2;
            result_type_label_trend.opacity = 0.2;
            result_type_label_x_bar.set_text ("x̄");

            switch (op) {
                case "GM":
                    result_type_label_g.opacity = 1;
                    result_type_label_m.opacity = 1;
                    break;
                case "n":
                    result_type_label_n.opacity = 1;
                    break;
                case "mode":
                    result_type_label_mode.opacity = 1;
                    break;
                case "M":
                    result_type_label_m.opacity = 1;
                    result_type_label_edia.opacity = 1;
                    result_type_label_n.opacity = 1;
                    break;
                case "sum":
                    result_type_label_summation.opacity = 1;
                    result_type_label_x_bar.opacity = 1;
                    result_type_label_x_bar.set_text ("x");
                    break;
                case "sumsq":
                    result_type_label_summation.opacity = 1;
                    result_type_label_x_bar.opacity = 1;
                    result_type_label_x_bar.set_text ("x");
                    result_type_label_x_sqr.opacity = 1;
                    break;
                case "SV":
                    result_type_label_sv.opacity = 1;
                    break;
                case "SD":
                    result_type_label_sd.opacity = 1;
                    break;
                case "mean":
                    result_type_label_x_bar.opacity = 1;
                    break;
                case "meansq":
                    result_type_label_x_bar.opacity = 1;
                    result_type_label_x_sqr.opacity = 1;
                    break;
                case "popvar":
                    result_type_label_sigma.opacity = 1;
                    result_type_label_sig_sqr.opacity = 1;
                    break;
                case "PSD":
                    result_type_label_sigma.opacity = 1;
                    break;
                case "trend":
                    result_type_label_trend.opacity = 1;
                    break;
            }
        }

        public void write (string str) {
            if (selected_cell != null) {
                selected_cell.text += str;
                selected_cell.set_position ((int) selected_cell.text_length);
            }
        }
    }
}
