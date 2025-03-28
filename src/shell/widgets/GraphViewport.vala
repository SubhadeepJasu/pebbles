namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/graph_viewport.ui")]
    public class GraphViewport : Gtk.Box {
        [GtkChild]
        private unowned Gtk.DrawingArea renderer;
        public int x_min { get; private set; }
        public int x_max { get; private set; }
        public int y_min { get; private set; }
        public int y_max { get; private set; }
        public GraphAxisScaling x_scaling_mode = LINEAR;
        public GraphAxisScaling y_scaling_mode = LINEAR;

        private Gdk.Pixbuf? figure;
        private bool valid_figure = true;

        construct {
            x_min = 0;
            y_min = 0;
            x_max = 10;
            y_max = 10;

            renderer.set_draw_func (draw_figure);
        }

        public void render (EquationModel[]? equations = null, GlobalAngleUnit angle_unit = DEG) {
            var window = (MainWindow) get_ancestor (typeof (MainWindow));

            var display = window.get_display ();
            var monitor = display.get_monitor_at_surface (window.get_surface ());

            var payload = new GraphPayloadModel () {
                equations = equations,
                angle_unit = angle_unit,
                x_min = this.x_min,
                x_max = this.x_max,
                y_min = this.y_min,
                y_max = this.y_max,
                x_scaling = x_scaling_mode,
                y_scaling = y_scaling_mode,
                width = renderer.get_width (),
                height = renderer.get_height (),
                dpi = monitor.get_geometry ().width / (monitor.get_width_mm () / 25.4),
                dark_mode = Gtk.Settings.get_default ().gtk_application_prefer_dark_theme
            };

            window.on_render_graph (payload);
        }

        public void show_graph (Gdk.Pixbuf? figure, bool valid) {
            this.figure = figure;
            valid_figure = valid;
            Idle.add_once (() => {
                renderer.queue_draw ();
            });
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
            }
        }
    }
}
