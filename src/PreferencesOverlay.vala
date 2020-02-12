/*-
 * Copyright (c) 2017-2019 Subhadeep Jasu <subhajasu@gmail.com>
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
 *              Saunak Biswas  <saunakbis97@gmail.com>
 */


namespace Pebbles { 
    public class PreferencesOverlay : Gtk.Window {
        public PreferencesOverlay () {
            var headerbar = new Gtk.HeaderBar ();
            headerbar.has_subtitle = false;
            headerbar.set_show_close_button (true);
            headerbar.title = "Preferences";

            headerbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            set_titlebar (headerbar);
            get_style_context ().add_class ("rounded");

            // Set up window attributes
            this.resizable = false;
            this.set_default_size (480, 480);
            this.set_size_request (480, 480);

            //this.add (scrolled_window);

            this.destroy_with_parent = true;
            this.modal = true;
            show_all ();
        }
    }
}