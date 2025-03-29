namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/graph_viewport.ui")]
    public class GraphViewport : Gtk.Box {
        [GtkChild]
        private unowned Gtk.DrawingArea renderer;
        private double _zoom_x;
        public double zoom_x {
            get {
                return _zoom_x;
            }

            set {
                _zoom_x = value;
                queue_render = true;
            }
        }
        private double _zoom_y;
        public double zoom_y {
            get {
                return _zoom_y;
            }

            set {
                _zoom_y = value;
                queue_render = true;
            }
        }

        private double _pan_x;
        public double pan_x {
            get {
                return _pan_x;
            }

            set {
                _pan_x = value;
                queue_render = true;
            }
        }

        private double _pan_y;
        public double pan_y {
            get {
                return _pan_y;
            }

            set {
                _pan_y = value;
                queue_render = true;
            }
        }

        public GraphAxisScaling x_scaling_mode = LINEAR;
        public GraphAxisScaling y_scaling_mode = LINEAR;

        private Gdk.Pixbuf? figure;
        private bool valid_figure = true;
        private GlobalAngleUnit angle_unit;
        private bool queue_render = false;
        private bool update = true;
        private int width;
        private int height;

        construct {
            renderer.set_draw_func (draw_figure);

            renderer.realize.connect (() => {
                width = renderer.get_width ();
                height = renderer.get_height ();

                Timeout.add (66, () => {
                    if (queue_render) {
                        queue_render = false;
                        rerender ();
                    } else if (width != renderer.get_width () || height != renderer.get_height ()) {
                        width = renderer.get_width ();
                        height = renderer.get_height ();
                        rerender ();
                    }

                    return update;
                }, Priority.DEFAULT_IDLE);
            });
        }

        ~GraphViewport () {
            update = Source.REMOVE;
        }

        private void rerender () {
            Idle.add_once (() => {
                render (null, angle_unit);
            });
        }

        public void render (EquationModel[]? equations = null, GlobalAngleUnit angle_unit = DEG) {
            this.angle_unit = angle_unit;

            var window = (MainWindow) get_ancestor (typeof (MainWindow));
            var display = window.get_display ();
            var monitor = display.get_monitor_at_surface (window.get_surface ());

            var payload = new GraphPayloadModel () {
                equations = equations,
                angle_unit = angle_unit,
                x_min = 0,
                x_max = 10,
                y_min = 0,
                y_max = 10,
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
                double degrees = Math.PI / 180.0;
                double radius = 3.0;
                cr.new_sub_path ();
                cr.arc (width - radius, radius, radius, -90 * degrees, 0);
                cr.arc (width - radius, height - radius, radius, 0, 90 * degrees);
                cr.arc (radius, height - radius, radius, 90 * degrees, 180 * degrees);
                cr.arc (radius, radius, radius, 180 * degrees, 270 * degrees);
                cr.close_path ();

                cr.clip ();


                int iwidth = figure?.get_width ();
                if (iwidth > 0) {
                    double scale_x = (double) width / iwidth;

                    cr.set_operator (Cairo.Operator.SOURCE);
                    cr.scale (scale_x, scale_x);
                    Gdk.cairo_set_source_pixbuf (
                        cr,
                        figure,
                        0,
                        0
                    );
                    cr.paint ();
                }
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
