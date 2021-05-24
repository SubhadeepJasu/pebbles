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

    // Specify the number system to use
    // Its used in programmer mode
    public enum NumberSystem {
        BINARY,
        OCTAL,
        DECIMAL,
        HEXADECIMAL
    }

    // Will be used to specify the variable constant key
    // both normal and alternative values.
    public enum ConstantKeyIndex {
        EULER          = 0,
        ARCHIMEDES     = 1,
        PARABOLIC      = 2,
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
        public int window_w {get; set;}
        public int window_h {get; set;}
        public bool window_maximized {get; set;}
        public int view_index {get; set;}
        public bool shift_alternative_function {get; set;}
        public GlobalAngleUnit global_angle_unit {get; set;}
        public GlobalWordLength global_word_length {get; set;}
        public NumberSystem number_system {get; set;}
        public bool use_dark_theme {get; set;}
        public ConstantKeyIndex constant_key_value1 {get; set;}
        public ConstantKeyIndex constant_key_value2 {get; set;}
        public int decimal_places {get; set;}
        public int integration_accuracy {get; set;}
        public string sci_input_text {get; set;}
        public string sci_output_text {get; set;}
        public string sci_memory_value {get; set;} 
        public string prog_input_text {get; set;}
        public string prog_output_text {get; set;}
        public string cal_input_text {get; set;}
        public string cal_output_text {get; set;}
        public string cal_integration_upper_limit {get; set;}
        public string cal_integration_lower_limit {get; set;}
        public string cal_derivation_limit {get; set;}
        public string stat_input_array {get; set;}
        public int stat_mode_previous {get; set;}
        public string stat_output_text {get; set;}
        public string currency_multipliers {get; set;}
        public string currency_update_date {get; set;}
        public string conv_length_from_entry {get; set;}
        public string conv_length_to_entry {get; set;}
        public string conv_area_from_entry {get; set;}
        public string conv_area_to_entry {get; set;}
        public string conv_angle_from_entry {get; set;}
        public string conv_angle_to_entry {get; set;}
        public string conv_volume_from_entry {get; set;}
        public string conv_volume_to_entry {get; set;}
        public string conv_time_from_entry {get; set;}
        public string conv_time_to_entry {get; set;}
        public string conv_speed_from_entry {get; set;}
        public string conv_speed_to_entry {get; set;}
        public string conv_mass_from_entry {get; set;}
        public string conv_mass_to_entry {get; set;}
        public string conv_pressure_from_entry {get; set;}
        public string conv_pressure_to_entry {get; set;}
        public string conv_energy_from_entry {get; set;}
        public string conv_energy_to_entry {get; set;}
        public string conv_power_from_entry {get; set;}
        public string conv_power_to_entry {get; set;}
        public string conv_temp_from_entry {get; set;}
        public string conv_temp_to_entry {get; set;}
        public string conv_data_from_entry {get; set;}
        public string conv_data_to_entry {get; set;}
        public string conv_curr_from_entry {get; set;}
        public string conv_curr_to_entry {get; set;}
        public string date_diff_from {get; set;}
        public string date_diff_to {get; set;}
        public string date_add_sub {get; set;}
        public string date_day_entry {get; set;}
        public string date_month_entry {get; set;}
        public string date_year_entry {get; set;}
        public string forex_api_key {get; set;}
        public string saved_history {get; set;}
        
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
