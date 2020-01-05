/*-
 * Copyright (c) 2017-2018 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright (c) 2017-2018 Saunak Biswas <saunakbis97@gmail.com>
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
    public class KeyboardMap {
        public enum KeyMap {
            NUMPAD_0     = 65456,
            NUMPAD_1     = 65457,
            NUMPAD_2     = 65458,
            NUMPAD_3     = 65459,
            NUMPAD_4     = 65460,
            NUMPAD_5     = 65461,
            NUMPAD_6     = 65462,
            NUMPAD_7     = 65463,
            NUMPAD_8     = 65464,
            NUMPAD_9     = 65465,
            NUMPAD_RADIX = 65454,
            KEYPAD_0     = 48,
            KEYPAD_1     = 49,
            KEYPAD_2     = 50,
            KEYPAD_3     = 51,
            KEYPAD_4     = 52,
            KEYPAD_5     = 53,
            KEYPAD_6     = 54,
            KEYPAD_7     = 55,
            KEYPAD_8     = 56,
            KEYPAD_9     = 57,
            KEYPAD_RADIX = 46,
            KEYPAD_COMMA = 44,
            F1           = 65470,
            F2           = 65471,
            F3           = 65472,
            F4           = 65473,
            F5           = 65474,
            F6           = 65475,
            F7           = 65476,
            F8           = 65477,
            F9           = 65478,
            F10          = 65479,
            F11          = 65480,
            F12          = 65481,
            BACKSPACE    = 65288,
            DELETE       = 65535,
            TAB          = 65289,
            SHIFT_TAB    = 65056,
            PAGE_UP      = 65365,
            PAGE_DOWN    = 65366,
            NUMPAD_HOME  = 65360,
            NUMPAD_END   = 65367
        }
        public static bool key_is_number (uint key) {
            if (((key >= KeyMap.NUMPAD_0) && (key <= KeyMap.NUMPAD_9))
             || ((key >= KeyMap.KEYPAD_0) && (key <= KeyMap.KEYPAD_9)))
                return true;
            return false;
        }
    }
}