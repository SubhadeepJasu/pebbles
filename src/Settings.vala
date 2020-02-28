/*-
 * Copyright (c) 2017-2020 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright (c) 2017-2020 Saunak Biswas <saunakbis97@gmail.com>
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

    // Specify angle unit to use (degrees, radians or gradient).
    // Its used in the upper left corner of the app.
    public enum GlobalAngleUnit {
        DEG  = 0,
        RAD  = 1,
        GRAD = 2
    }

    // Specify the word length to use (qword, dword, word or byte)
    // Its used in the upper left corner of the app.
    public enum GlobalWordLength {
        QWD  = 0,
        DWD  = 1,
        WRD  = 2,
        BYT  = 3
    }

    // Will be used to specify the variable constant key
    // both normal and alternative values.
    public enum ConstantKeyIndex {
        EULER          = 0,
        ARCHIMEDES     = 1,
        IMAGINARY      = 2,
        GOLDEN_RATIO   = 3,
        EULER_MASCH    = 4,
        CONWAY         = 5,
        KHINCHIN       = 6,
        FEIGEN_ALPHA   = 7,
        FEIGEN_DELTA   = 8,
        APERY          = 9
    }

    public class Settings : Granite.Services.Settings {
        private static Settings settings;
        public static Settings get_default () {
            if (settings == null) {
                settings = new Settings ();
            }
            return settings;
        }
        public int window_x {get; set;}
        public int window_y {get; set;}
        public bool shift_alternative_function {get; set;}
        public GlobalAngleUnit global_angle_unit {get; set;}
        public GlobalWordLength global_word_length {get; set;}
        public bool use_dark_theme {get; set;}
        public ConstantKeyIndex constant_key_value1 {get; set;}
        public ConstantKeyIndex constant_key_value2 {get; set;}
        public int decimal_places {get; set;}
        
        private Settings () {
            base ("com.github.subhadeepjasu.pebbles");
        }
        
        public void switch_angle_unit () {
            switch (settings.global_angle_unit) {
                case GlobalAngleUnit.RAD:
                    settings.global_angle_unit = GlobalAngleUnit.GRAD;
                    break;
                case GlobalAngleUnit.GRAD:
                    settings.global_angle_unit = GlobalAngleUnit.DEG;
                    break;
                default:
                    settings.global_angle_unit = GlobalAngleUnit.RAD;
                    break;
            }
        }
        
        public void switch_word_length () {
            switch (settings.global_word_length) {
                case GlobalWordLength.DWD:
                    settings.global_word_length = GlobalWordLength.WRD;
                    break;
                case GlobalWordLength.WRD:
                    settings.global_word_length = GlobalWordLength.BYT;
                    break;
                case GlobalWordLength.BYT:
                    settings.global_word_length = GlobalWordLength.QWD;
                    break;
                default:
                    settings.global_word_length = GlobalWordLength.DWD;
                    break;
            }
        }
    }
 }
