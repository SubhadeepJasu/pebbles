// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>

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

        private double _var_a;
        public double var_a {
            get {
                return _var_a;
            }

            set {
                _var_a = value;
                queue_render = true;
            }
        }
        private double _var_b;
        public double var_b {
            get {
                return _var_b;
            }

            set {
                _var_b = value;
                queue_render = true;
            }
        }
        private double _var_c;
        public double var_c {
            get {
                return _var_c;
            }

            set {
                _var_c = value;
                queue_render = true;
            }
        }
        private double _var_m;
        public double var_m {
            get {
                return _var_m;
            }

            set {
                _var_m = value;
                queue_render = true;
            }
        }

        private bool _dragging = false;
        private bool dragging {
            get {
                return _dragging;
            }

            set {
                _dragging = value;
                queue_render = true;
            }
        }

        private bool scrolling = false;

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

        [GtkChild]
        private unowned Gtk.DrawingArea x_axis_meter;
        [GtkChild]
        private unowned Gtk.DrawingArea y_axis_meter;

        private Gtk.EventControllerScroll main_scroll_gesture;
        private Gtk.EventControllerScroll x_scroll_gesture;
        private Gtk.EventControllerScroll y_scroll_gesture;
        private Gtk.Settings gtk_settings;

        construct {
            gtk_settings = Gtk.Settings.get_default ();
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

            x_axis_meter.set_draw_func (draw_x_scale);
            y_axis_meter.set_draw_func (draw_y_scale);

            pan_gesture = new Gtk.GestureDrag () {
                propagation_phase = Gtk.PropagationPhase.CAPTURE,
                name = "drag-rotation-capture"
            };

            pan_gesture.begin.connect (() => {
                dragging = true;
            });

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
                dragging = false;
            });
            add_controller (pan_gesture);

            zoom_gesture = new Gtk.GestureZoom () {
                propagation_phase = Gtk.PropagationPhase.CAPTURE,
                name = "zoom-rotation-capture"
            };
            zoom_gesture.begin.connect (() => {
                previous_sx = zoom_x;
                previous_sy = zoom_y;
                dragging = true;
            });
            zoom_gesture.scale_changed.connect ((off_s) => {
                zoom_x = previous_sx * off_s;
                zoom_y = previous_sy * off_s;
                dragging = true;
            });
            zoom_gesture.end.connect (() => {
                dragging = false;
            });
            add_controller (zoom_gesture);

            main_scroll_gesture = new Gtk.EventControllerScroll (Gtk.EventControllerScrollFlags.BOTH_AXES) {
                propagation_phase = Gtk.PropagationPhase.CAPTURE
            };
            main_scroll_gesture.scroll.connect ((dx, dy) => {
                dragging = true;
                scrolling = true;
                var modifier = main_scroll_gesture.get_current_event_state ();
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
            main_scroll_gesture.scroll_end.connect (() => {
                dragging = false;
                scrolling = false;
            });
            add_controller (main_scroll_gesture);

            x_scroll_gesture = new Gtk.EventControllerScroll (Gtk.EventControllerScrollFlags.BOTH_AXES);
            y_scroll_gesture = new Gtk.EventControllerScroll (Gtk.EventControllerScrollFlags.BOTH_AXES);

            x_scroll_gesture.scroll.connect ((dx, dy) => {
                var dv = dx + dy;
                var new_zoom_x = zoom_x - dv;
                if (new_zoom_x > 0) {
                    zoom_x = new_zoom_x;
                }
            });

            y_scroll_gesture.scroll.connect ((dx, dy) => {
                var dv = dx + dy;
                var new_zoom_y = zoom_y - dv;
                if (new_zoom_y > 0) {
                    zoom_y = new_zoom_y;
                }
            });

            x_axis_meter.add_controller (x_scroll_gesture);
            y_axis_meter.add_controller (y_scroll_gesture);
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
                var_a = var_a,
                var_b = var_b,
                var_c = var_c,
                var_m = var_m,
                x_min = (pan_x - (zoomed_width / 2)),
                x_max = (pan_x + (zoomed_width / 2)),
                y_min = (pan_y - (zoomed_height / 2)),
                y_max = (pan_y + (zoomed_height / 2)),
                x_scaling = x_scaling_mode,
                y_scaling = y_scaling_mode,
                width = renderer.get_width (),
                height = renderer.get_height (),
                dpi = dpi,
                dark_mode = gtk_settings.gtk_application_prefer_dark_theme,
                fidelity_mode = !dragging
            };

            window.on_render_graph (payload);
        }

        public void show_graph (Gdk.Pixbuf? figure, bool valid) {
            this.figure = figure;
            valid_figure = valid;
            Idle.add_once (() => {
                renderer.queue_draw ();
                x_axis_meter.queue_draw ();
                y_axis_meter.queue_draw ();
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

            if (scrolling) {
                dragging = false;
                scrolling = false;
                renderer.queue_draw ();
            }
        }

        private void draw_x_scale (Gtk.DrawingArea area, Cairo.Context cr, int width, int height) {
            double base_spacing = 10.0;
            double spacing = (zoom_x / 100.0) * base_spacing;

            if (gtk_settings.gtk_application_prefer_dark_theme) {
                cr.set_source_rgb (0.8, 0.8, 0.8);
            } else {
                cr.set_source_rgb (0.2, 0.2, 0.2);
            }
            cr.set_line_width (1.0);

            cr.move_to (0, height - 1);
            cr.line_to (width, height - 1);
            cr.stroke ();

            double major_tick = height / 3;
            double medium_tick = height / 4;
            double minor_tick = height / 5;

            for (double x = 0; x < width; x += spacing) {
                bool is_major = true;
                bool is_medium = false;
                bool is_minor = false;

                if (zoom_x > 200) {
                    int index = (int) (x / spacing);
                    is_major = (index % 10 == 0);
                    is_medium = (index % 5 == 0) && !is_major;
                    is_minor = !is_major && !is_medium;
                } else if (zoom_x > 100) {
                    int index = (int) (x / spacing);
                    is_major = (index % 5 == 0);
                    is_medium = !is_major;
                } else {
                    is_major = true;
                }

                double tick_height = is_major ? major_tick : (is_medium ? medium_tick : minor_tick);

                cr.move_to (x, height - 1);
                cr.line_to (x, height - 1 - tick_height);
                cr.stroke ();
            }

            string label = x_scaling_mode == LINEAR ? "LINEAR" : "LOGARITHMIC";
            cr.select_font_face ("Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
            cr.set_font_size (12);

            Cairo.TextExtents extents;
            cr.text_extents (label, out extents);

            double x_center = (width - extents.width) / 2 - extents.x_bearing;
            double y_offset = extents.height + 2;

            cr.move_to (x_center, y_offset);
            cr.show_text (label);
        }

        private void draw_y_scale (Gtk.DrawingArea area, Cairo.Context cr, int width, int height) {
            double base_spacing = 10.0;
            double spacing = (zoom_y / 100.0) * base_spacing;

            if (gtk_settings.gtk_application_prefer_dark_theme) {
                cr.set_source_rgb (0.8, 0.8, 0.8);
            } else {
                cr.set_source_rgb (0.2, 0.2, 0.2);
            }
            cr.set_line_width (1.0);

            cr.move_to (width - 1, 0);
            cr.line_to (width - 1, height);
            cr.stroke ();

            double major_tick = width / 3;
            double medium_tick = width / 4;
            double minor_tick = width / 5;

            for (double y = 0; y < height; y += spacing) {
                bool is_major = true;
                bool is_medium = false;
                bool is_minor = false;

                if (zoom_y > 200) {
                    int index = (int)(y / spacing);
                    is_major = (index % 10 == 0);
                    is_medium = ((index % 5 == 0) && !is_major);
                    is_minor = !is_major && !is_medium;
                } else if (zoom_y > 100) {
                    int index = (int)(y / spacing);
                    is_major = (index % 5 == 0);
                    is_medium = !is_major;
                } else {
                    is_major = true;
                }

                double tick_length = is_major ? major_tick : (is_medium ? medium_tick : minor_tick);
                cr.move_to (width - 1, y);
                cr.line_to (width - 1 - tick_length, y);
                cr.stroke ();
            }

            string label = y_scaling_mode == LINEAR ? "LINEAR" : "LOGARITHMIC";
            cr.select_font_face ("Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
            cr.set_font_size (12);

            Cairo.TextExtents extents;
            cr.text_extents (label, out extents);

            double y_center = (height - extents.width) / 2 - extents.x_bearing;
            double x_offset = width - extents.height - major_tick - 4;

            cr.move_to (x_offset, y_center);
            cr.rotate (Math.PI_2);
            cr.show_text (label);
            cr.restore ();
        }

        [GtkCallback]
        protected void toggle_x_scaling () {
            if (x_scaling_mode == LINEAR) {
                x_scaling_mode = LOGARITHMIC;
            } else {
                x_scaling_mode = LINEAR;
            }

            queue_render = true;
        }

        [GtkCallback]
        protected void toggle_y_scaling () {
            if (y_scaling_mode == LINEAR) {
                y_scaling_mode = LOGARITHMIC;
            } else {
                y_scaling_mode = LINEAR;
            }

            queue_render = true;
        }

        [GtkCallback]
        protected void reset_view () {
            zoom_x = 100;
            zoom_y = 100;
            pan_x = 0;
            pan_y = 0;
        }
    }
}
