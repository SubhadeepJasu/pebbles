namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/statistics_display.ui")]
    public class StatisticsDisplay : Display {
        public string add_cell_warning_text { get; construct; }

        [GtkChild]
        private unowned Gtk.Box data_table;
        [GtkChild]
        private unowned Gtk.Label add_cell_warning;
        [GtkChild]
        private unowned Gtk.DrawingArea plot;

        private List<Gtk.Entry?> cells;
        private Gdk.Pixbuf plot_visual;

        construct {
            add_cell_warning_text = "▭+  " + _("Enter data by adding new cell");
            plot.set_draw_func (draw);
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

        public double[] confirm_data (out double width, out double height) {
            uint n = cells.length ();
            var result = new double[n];
            for (uint i = 0; i < n; i++) {
                result[i] = double.parse (cells.nth_data (i).text);
            }

            width = plot.get_width ();
            height = plot.get_height ();
            return result;
        }

        public void plot_visualization (Gdk.Pixbuf pixbuf) {
            if (pixbuf != null) {
                plot_visual = pixbuf;
                plot.queue_draw ();
            }
        }

        private void draw (Gtk.DrawingArea area, Cairo.Context cr, int width, int height) {
            if (plot_visual != null) {
                Gdk.cairo_set_source_pixbuf (cr, plot_visual, 0, 0);
                cr.paint ();
            } else {
                // Draw error message
                cr.set_source_rgb (1, 0, 0); // Red
                cr.select_font_face ("Sans", NORMAL, BOLD);
                cr.set_font_size (12);
                cr.move_to (2, 50);
                cr.show_text ("Failed to load image!");
            }

        }
    }
}
