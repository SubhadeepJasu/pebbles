namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/graph_viewport.ui")]
    public class GraphViewport : Gtk.Box {
        [GtkChild]
        private unowned Gtk.DrawingArea renderer;
        private double _zoom_x = 100;
        public double zoom_x {
            get {
                return _zoom_x;
            }

            set {
                _zoom_x = value;
                queue_render = true;
            }
        }
        private double _zoom_y = 100;
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


        private double dpi;
        private Gtk.GestureDrag pan_gesture;
        private double previous_x = 0;
        private double previous_y = 0;

        private Gtk.GestureZoom zoom_gesture;
        private double previous_sx = 0;
        private double previous_sy = 0;

        private Gtk.EventControllerScroll scroll_gesture;

        construct {
            renderer.set_draw_func (draw_figure);

            renderer.realize.connect (() => {
                var window = (MainWindow) get_ancestor (typeof (MainWindow));
                var display = window.get_display ();
                var monitor = display.get_monitor_at_surface (window.get_surface ());

                dpi = monitor.get_geometry ().width / (monitor.get_width_mm () / 25.4);

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

            pan_gesture = new Gtk.GestureDrag () {
                propagation_phase = Gtk.PropagationPhase.CAPTURE,
                name = "drag-rotation-capture"
            };
            pan_gesture.drag_update.connect ((off_x, off_y) => {
                var vel_x = off_x - previous_x;
                previous_x = off_x;
                pan_x -= vel_x / zoom_x;

                var vel_y = off_y - previous_y;
                previous_y = off_y;
                pan_y += vel_y / zoom_y;
            });
            pan_gesture.drag_end.connect (() => {
                previous_x = 0;
                previous_y = 0;
            });
            add_controller (pan_gesture);

            zoom_gesture = new Gtk.GestureZoom () {
                propagation_phase = Gtk.PropagationPhase.CAPTURE,
                name = "zoom-rotation-capture"
            };
            zoom_gesture.begin.connect (() => {
                previous_sx = zoom_x;
                previous_sy = zoom_y;
            });
            zoom_gesture.scale_changed.connect ((off_s) => {
                zoom_x = previous_sx * off_s;
                zoom_y = previous_sy * off_s;
            });
            add_controller (zoom_gesture);

            scroll_gesture = new Gtk.EventControllerScroll (Gtk.EventControllerScrollFlags.BOTH_AXES);
            scroll_gesture.scroll.connect ((dx, dy) => {
                var modifier = scroll_gesture.get_current_event_state ();
                if ((modifier & Gdk.ModifierType.CONTROL_MASK) != 0) {
                    var new_zoom_x = zoom_x - dy;
                    var new_zoom_y = zoom_y - dy;

                    if (new_zoom_x > 0 && new_zoom_y > 0) {
                        zoom_x = new_zoom_x;
                        zoom_y = new_zoom_y;
                    }
                } else {
                    pan_x += dx / dpi;
                    pan_y -= dy / dpi;
                }
            });
            add_controller (scroll_gesture);
        }

        ~GraphViewport () {
            update = Source.REMOVE;
        }

        private void rerender () {
            render (null, angle_unit);
        }

        public void render (EquationModel[]? equations = null, GlobalAngleUnit angle_unit = DEG) {
            this.angle_unit = angle_unit;

            var window = (MainWindow) get_ancestor (typeof (MainWindow));

            var zoomed_width = renderer.get_width () / zoom_x;
            var zoomed_height = renderer.get_height () / zoom_y;

            var payload = new GraphPayloadModel () {
                equations = equations,
                angle_unit = angle_unit,
                x_min = (pan_x - (zoomed_width / 2)),
                x_max = (pan_x + (zoomed_width / 2)),
                y_min = (pan_y - (zoomed_height / 2)),
                y_max = (pan_y + (zoomed_height / 2)),
                x_scaling = x_scaling_mode,
                y_scaling = y_scaling_mode,
                width = renderer.get_width (),
                height = renderer.get_height (),
                dpi = dpi,
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
