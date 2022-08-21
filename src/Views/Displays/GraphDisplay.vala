/*-
 * Copyright (c) 2022-2023 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 */

namespace Pebbles {
    public class GraphDisplay : Gtk.Grid {
        // Status bar
        Gtk.Grid lcd_status_bar;
        Gtk.Label deg_label;
        Gtk.Label rad_label;
        Gtk.Label grad_label;
        Gtk.Label shift_label;

        // Graphs
        List<Graph> graphs;

        // Drawing area
        Gtk.DrawingArea drawing_area;
        double x_offset = 0;
        double y_offset = 0;

        bool dragging = false;
        double _x = 0;
        double _y = 0;
        double _last_x = 0;
        double _last_y = 0;

        public GraphDisplay () {
            // Stylize background;
            get_style_context ().add_class ("Pebbles_Display_Unit_Bg");

            // Make status bar
            lcd_status_bar = new Gtk.Grid ();
            deg_label      = new Gtk.Label ("DEG");
            deg_label.get_style_context ().add_class ("pebbles_h4");
            rad_label      = new Gtk.Label ("RAD");
            rad_label.get_style_context ().add_class ("pebbles_h4");
            grad_label     = new Gtk.Label ("GRA");
            grad_label.get_style_context ().add_class ("pebbles_h4");
            shift_label    = new Gtk.Label (_("SHIFT"));
            shift_label.get_style_context ().add_class ("pebbles_h4");
            shift_label.set_opacity (0.2);
            shift_label.set_halign (Gtk.Align.END);
            shift_label.hexpand = true;

            var angle_mode_display = new Gtk.Grid ();
            angle_mode_display.attach (deg_label,  0, 0, 1, 1);
            angle_mode_display.attach (rad_label,  1, 0, 1, 1);
            angle_mode_display.attach (grad_label, 2, 0, 1, 1);
            angle_mode_display.column_spacing = 10;
            angle_mode_display.set_halign (Gtk.Align.START);

            lcd_status_bar.attach (angle_mode_display, 0, 0);
            lcd_status_bar.attach (shift_label, 1, 0);
            lcd_status_bar.width_request = 200;
            lcd_status_bar.set_halign (Gtk.Align.FILL);
            lcd_status_bar.hexpand = true;

            var drawing_area_overlay = new Gtk.Overlay ();

            drawing_area = new Gtk.DrawingArea () {
                hexpand = true,
                vexpand = true
            };
            drawing_area_overlay.add (drawing_area);
            drawing_area.draw.connect(draw_graph);

            var event_box = new Gtk.EventBox ();
            drawing_area_overlay.add_overlay (event_box);

            event_box.button_press_event.connect((event) => {
                dragging = true;
                _last_x = x_offset;
                _last_y = y_offset;
                _x = event.x;
                _y = event.y;
                return false;
            });

            event_box.button_release_event.connect((event) => {
                dragging = false;
                return false;
            });

            event_box.motion_notify_event.connect((event) => {
                if (dragging) {
                    x_offset = _last_x + (event.x - _x) ;
                    y_offset = _last_y + (event.y - _y);
                }

                drawing_area.queue_draw();
                return false;
            });

            // Put it together
            attach (lcd_status_bar, 0, 0, 1, 1);
            attach (drawing_area_overlay, 0, 1, 1, 1);
            width_request = 320;

            graphs = new List<Graph>();

            graphs.append(new Graph("sin x"));
        }


        private bool draw_graph(Cairo.Context context) {
            int width = drawing_area.get_allocated_width ();
            int height = drawing_area.get_allocated_height ();

            context.set_source_rgba (0.152941176, 0.156862745, 0.388235294, 0.8);
	        context.set_line_width (1);
            context.set_dash ({4, 1}, 0);

	        context.move_to (x_offset + width / 2, 0);
	        context.line_to (x_offset + width / 2, height);
	        context.stroke ();

	        context.move_to (0, y_offset + height / 2);
	        context.line_to (width, y_offset + height / 2);
	        context.stroke ();

	        context.set_source_rgba (1, 0, 0, 1);
	        context.set_dash ({1, 0}, 0);

	        double plot_x = 0;
	        double plot_y = 0;

	        double zoomLevel = 50;

	        foreach (var graph in graphs) {
	            context.move_to (0, y_offset + height / 2);
	            for (double x = 0; x < width; x++) {
	                var y = graph.plot_y((x - (width / 2) - x_offset) / zoomLevel, zoomLevel);
	                // print("%lf>%lf ", x - width / 2, y);
	                context.line_to (x, y_offset + (height / 2) - y);
	            }
	            context.stroke ();
	        }

	        return false;
        }
    }
}
