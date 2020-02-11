/*-
 * Copyright (c) 2018-2019 Subhadeep Jasu <subhajasu@gmail.com>
 *               2018-2019 Saunak Biswas  <saunakbis97@gmail.com>
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
    public class StyledButton : Gtk.Button {
        Gtk.Label label_text;
        public StyledButton (string label_text, string? tooltip_desc = null, string[]? accel_markup = null) {
            this.label_text = new Gtk.Label (label_text);
            this.label_text.use_markup = true;
            image = this.label_text;
            if (accel_markup != null) {
                tooltip_markup = Granite.markup_accel_tooltip (accel_markup, tooltip_desc);
            } else {
                tooltip_text = tooltip_desc;
            }
        }
        public void update_label (string label_text, string? tooltip_desc = null, string[]? accel_markup = null) {
            this.label_text.set_text (label_text);
            this.label_text.use_markup = true;
            image = this.label_text;
            if (accel_markup != null) {
                tooltip_markup = Granite.markup_accel_tooltip (accel_markup, tooltip_desc);
            } else {
                tooltip_text = tooltip_desc;
            }
            get_style_context ().remove_class ("image-button");
        }
    }
}
