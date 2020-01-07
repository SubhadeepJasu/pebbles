/*-
 * Copyright (c) 2017-2018 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright (c) 2018-2019 Saunak Biswas  <saunakbis97@gmail.com>
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
    public class ControlsOverlay : Gtk.Window {
        public ControlsOverlay () {
            ControlScheme scheme = new ControlScheme ();

            var main_grid = new Gtk.Grid ();
            main_grid.margin = 8;

            main_grid.attach (new Granite.HeaderLabel (_("Common")), 0, 0, 1, 1);

            var common_grid = new Gtk.Grid ();
            common_grid.margin_start = 8;
            common_grid.margin_end = 8;
            common_grid.row_spacing = 4;
            for (int i = 0; i < scheme.common.length[0]; i++) {
                common_grid.attach (new Granite.AccelLabel (scheme.common[i, 0], scheme.common[i, 1]), 0, i, 1, 1);
            }
            main_grid.attach (common_grid, 0, 1, 1, 1);

            main_grid.attach (new Granite.HeaderLabel (_("Statistics")), 0, 2, 1, 1);

            var statistics_grid = new Gtk.Grid ();
            statistics_grid.margin_start = 8;
            statistics_grid.margin_end = 8;
            statistics_grid.row_spacing = 4;
            for (int i = 0; i < scheme.statistics.length[0]; i++) {
                statistics_grid.attach (new Granite.AccelLabel (scheme.statistics[i, 0], scheme.statistics[i, 1]), 0, i, 1, 1);
            }

            main_grid.attach (statistics_grid, 0, 3, 1, 1);

            var scrolled_window = new Gtk.ScrolledWindow (null, null);
            scrolled_window.add (main_grid);
            scrolled_window.width_request = 300;
            scrolled_window.height_request = 200;


            var headerbar = new Gtk.HeaderBar ();
            headerbar.has_subtitle = false;
            headerbar.set_show_close_button (true);
            headerbar.title = "Pebbles Controls";

            headerbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            set_titlebar (headerbar);
            get_style_context ().add_class ("rounded");

            // Set up window attributes
            this.resizable = false;
            this.set_default_size (300, 200);
            this.set_size_request (300, 200);

            this.add (scrolled_window);

            this.destroy_with_parent = true;
            this.modal = true;
            show_all ();
        }
    }
}