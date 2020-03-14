/*-
 * Copyright (c) 2017-2020 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright (c) 2017-2020 Saunak Biswas  <saunakbis97@gmail.com>
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
    public class StatisticsGraph : Gtk.DrawingArea {
        private int cardinality;
        private double[] data_set;

        private const double scale_x = 140;
        private const double scale_y = 56;

        public void set_data_set (string[] data_points) {
            data_set = new double[data_points.length];
            for (int i = 0; i < data_points.length; i++) {
                data_set[i] = data_points[i].to_double ();
            }
            this.cardinality = data_points.length;
        }

        public StatisticsGraph () {
            this.draw.connect (on_draw);
            this.width_request = 140;
            this.queue_draw ();
            this.show_all ();

            //  data_set = {1, 2, 4, -1, -3};
            //  cardinality = data_set.length;
        }

        bool on_draw (Gtk.Widget widget, Cairo.Context context) {
            // Draw lines:
            context.set_source_rgba (0.152941176, 0.156862745, 0.388235294, 0.8);

            if (cardinality != 0 && data_set != null) {
                double max_point = highest_point (data_set);
                double min_point = lowest_point (data_set);
                double max_height = max_point - min_point;
                stdout.printf ("max: %lf, min: %lf\n", max_point, min_point);
    
                int baseline = (int)(-scale_y * (min_point / max_height));
    
                double line_width = (scale_x / cardinality);
                double gap = (line_width/4).clamp (0, 2);
                
                // Draw bars as per data points
                for (int i = 0; i < cardinality; i++) {
                    draw_bar (context, (int)(line_width - gap), (int)((data_set[i]/max_height) * scale_y), (int)(i * line_width), baseline);
                    stdout.printf ("%d\n", i);
                }
            }

            return true;
        }

        private void draw_bar (Cairo.Context ctx, int width, int height, int x_offset, int y_offset) {
            ctx.set_line_width (width);
            ctx.move_to (x_offset + (width/2), 2 + scale_y - (y_offset));
            ctx.line_to (x_offset + (width/2), 2 + scale_y - (height + y_offset));
            ctx.stroke ();
        }

        private double lowest_point (double[] arr) {
            double x = 0;
            for (int i = 0; i < arr.length; i++) {
                if (arr[i] < x) {
                    x = arr[i];
                }
            }
            return x;
        }

        private double highest_point (double[] arr) {
            double x = 0;
            for (int i = 0; i < arr.length; i++) {
                if (arr[i] > x) {
                    x = arr[i];
                }
            }
            return x;
        }
    }
}