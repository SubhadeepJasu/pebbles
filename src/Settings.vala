/*
 * Copyright 2019-2026 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Pebbles {
    public class Settings : GLib.Settings {
        private static Settings settings;
        public static Settings get_default () {
            if (settings == null) {
                settings = new Pebbles.Settings (Config.SCHEMA_ID);
            }
            return settings;
        }

        // Keys
        public const string KEY_VERSION = "version";
        public const string KEY_LOAD_LAST_SESSION = "load-last-session";
        public const string KEY_RESULT_FLOW = "result-flow";
        public const string KEY_THEME = "theme";
        public const string KEY_CONSTANT_KEY_VALUE1 = "constant-key-value1";
        public const string KEY_CONSTANT_KEY_VALUE2 = "constant-key-value2";
        public const string KEY_DECIMAL_PLACES = "decimal-places";
        public const string KEY_INTEGRATION_RESOLUTION = "integration-resolution";
        public const string KEY_DERIVATIVE_ACCURACY = "derivative-accuracy";
        public const string KEY_CALCULUS_MODE = "calculus-mode";
        public const string KEY_FOREX_API_KEY = "forex-api-key";
        public const string KEY_FOREX_API_TIMESTAMP = "forex-timestamp";
        public const string KEY_FOREX_RATES_CACHE = "forex-rates-cache";
        public const string KEY_GLOBAL_ANGLE_UNIT = "global-angle-unit";
        public const string KEY_GLOBAL_WORD_LENGTH = "global-word-length";
        public const string KEY_NUMBER_SYSTEM = "number-system";
        public const string KEY_LAST_INPUT_SCIENTIFIC = "last-input-scientific";
        public const string KEY_LAST_INPUT_PROGRAMMER = "last-input-programmer";
        public const string KEY_LAST_INPUT_CALCULUS = "last-input-calculus";
        public const string KEY_LAST_INPUT_CALCULUS_X = "last-input-calculus-x";
        public const string KEY_LAST_INPUT_CALCULUS_UPPER_LIM = "last-input-calculus-upper-lim";
        public const string KEY_LAST_INPUT_CALCULUS_LOWER_LIM = "last-input-calculus-lower-lim";
        public const string KEY_LAST_INPUT_GRAPHING = "last-input-graphing";
        public const string KEY_DATE_DIFF_FROM = "date-diff-from";
        public const string KEY_DATE_DIFF_TO = "date-diff-to";
        public const string KEY_DATE_STARTING_FROM = "date-starting-from";
        public const string KEY_DATE_ADD_DAYS = "date-add-days";
        public const string KEY_DATE_ADD_MONTHS = "date-add-months";
        public const string KEY_DATE_ADD_YEARS = "date-add-years";
        public const string KEY_DIFF_MODE_DUR = "diff-mode-dur";
        public const string KEY_DATE_FIND_MODE = "date-find-mode";
        public const string KEY_LAST_OUTPUT_SCIENTIFIC = "last-output-scientific";
        public const string KEY_LAST_OUTPUT_PROGRAMMER = "last-output-programmer";
        public const string KEY_LAST_OUTPUT_CALCULUS = "last-output-calculus";
        public const string KEY_LAST_OUTPUT_STATISTICS = "last-output-statistics";
        public const string KEY_CONV_FROM_SUFFIX = "-from";
        public const string KEY_CONV_FROM_UNIT_SUFFIX = "-from-unit";
        public const string KEY_CONV_TO_UNIT_SUFFIX = "-to-unit";

        public Settings (string schema_id) {
            Object (
                schema_id: schema_id
            );
        }

        public void reset_all () {
            List<string> keys = new List<string> ();
            keys.append (KEY_GLOBAL_ANGLE_UNIT);
            keys.append (KEY_GLOBAL_WORD_LENGTH);
            keys.append (KEY_NUMBER_SYSTEM);
            keys.append (KEY_CALCULUS_MODE);
            keys.append (KEY_LAST_INPUT_SCIENTIFIC);
            keys.append (KEY_LAST_INPUT_PROGRAMMER);
            keys.append (KEY_LAST_INPUT_CALCULUS);
            keys.append (KEY_LAST_INPUT_GRAPHING);
            keys.append (KEY_DATE_DIFF_FROM);
            keys.append (KEY_DATE_DIFF_TO);
            keys.append (KEY_DATE_STARTING_FROM);
            keys.append (KEY_DATE_ADD_DAYS);
            keys.append (KEY_DATE_ADD_MONTHS);
            keys.append (KEY_DATE_ADD_YEARS);
            keys.append (KEY_DIFF_MODE_DUR);
            keys.append (KEY_DATE_FIND_MODE);
            keys.append (KEY_LAST_OUTPUT_SCIENTIFIC);
            keys.append (KEY_LAST_OUTPUT_PROGRAMMER);
            keys.append (KEY_LAST_OUTPUT_CALCULUS);
            keys.append (KEY_LAST_OUTPUT_STATISTICS);

            const string[] CONVERTER_PREFIXES = {
                Context.CONV_LEN,
                Context.CONV_AREA,
                Context.CONV_VOL,
                Context.CONV_TIME,
                Context.CONV_ANGLE,
                Context.CONV_SPEED,
                Context.CONV_MASS,
                Context.CONV_PRES,
                Context.CONV_ENERGY,
                Context.CONV_POWER,
                Context.CONV_TEMP,
                Context.CONV_DATA,
                Context.CONV_CURR
            };

            foreach (var item in CONVERTER_PREFIXES) {
                var conv_key = item.replace (".", "-");
                keys.append (conv_key + KEY_CONV_FROM_SUFFIX);
                keys.append (conv_key + KEY_CONV_FROM_UNIT_SUFFIX);
                keys.append (conv_key + KEY_CONV_TO_UNIT_SUFFIX);
            }

            foreach (var item in keys) {
                reset (item);
            }
        }

        public string version {
            owned get { return get_string (KEY_VERSION); }
            set { set_string (KEY_VERSION, value); }
        }

        public bool load_last_session {
            get { return get_boolean (KEY_LOAD_LAST_SESSION); }
            set { set_boolean (KEY_LOAD_LAST_SESSION, value); }
        }

        public bool result_flow {
            get { return get_boolean (KEY_RESULT_FLOW); }
            set { set_boolean (KEY_RESULT_FLOW, value); }
        }

        public string theme {
            owned get { return get_string (KEY_THEME); }
            set { set_string (KEY_THEME, value); }
        }

        public ConstantKeyIndex constant_key_value1 {
            get { return get_enum (KEY_CONSTANT_KEY_VALUE1); }
            set { set_enum (KEY_CONSTANT_KEY_VALUE1, value); }
        }

        public ConstantKeyIndex constant_key_value2 {
            get { return get_enum (KEY_CONSTANT_KEY_VALUE2); }
            set { set_enum (KEY_CONSTANT_KEY_VALUE2, value); }
        }

        public uint decimal_places {
            get { return get_uint (KEY_DECIMAL_PLACES); }
            set { set_uint (KEY_DECIMAL_PLACES, value); }
        }

        public uint integration_resolution {
            get { return get_uint (KEY_INTEGRATION_RESOLUTION); }
            set { set_uint (KEY_INTEGRATION_RESOLUTION, value); }
        }

        public uint derivative_accuracy {
            get { return get_uint (KEY_DERIVATIVE_ACCURACY); }
            set { set_uint (KEY_DERIVATIVE_ACCURACY, value); }
        }

        public string forex_api_key {
            owned get { return get_string (KEY_FOREX_API_KEY); }
            set { set_string (KEY_FOREX_API_KEY, value); }
        }

        public uint forex_api_last_updated {
            get { return get_uint (KEY_FOREX_API_TIMESTAMP); }
            set { set_uint (KEY_FOREX_API_TIMESTAMP, value); }
        }

        public string[] forex_rates_cache {
            owned get { return get_strv (KEY_FOREX_RATES_CACHE); }
            set { set_strv (KEY_FOREX_RATES_CACHE, value); }
        }

        // State Saving
        public GlobalAngleUnit global_angle_unit {
            get { return get_enum (KEY_GLOBAL_ANGLE_UNIT); }
            set { set_enum (KEY_GLOBAL_ANGLE_UNIT, value); }
        }

        public GlobalWordLength global_word_length {
            get { return get_enum (KEY_GLOBAL_WORD_LENGTH); }
            set { set_enum (KEY_GLOBAL_WORD_LENGTH, value); }
        }

        public NumberSystem number_system {
            get { return get_enum (KEY_NUMBER_SYSTEM); }
            set { set_enum (KEY_NUMBER_SYSTEM, value); }
        }

        public bool calculus_mode {
            get { return get_boolean (KEY_CALCULUS_MODE); }
            set { set_boolean (KEY_CALCULUS_MODE, value); }
        }

        public string last_input_scientific {
            owned get { return get_string (KEY_LAST_INPUT_SCIENTIFIC); }
            set { set_string (KEY_LAST_INPUT_SCIENTIFIC, value); }
        }

        public string last_input_programmer {
            owned get { return get_string (KEY_LAST_INPUT_PROGRAMMER); }
            set { set_string (KEY_LAST_INPUT_PROGRAMMER, value); }
        }

        public string last_input_calculus {
            owned get { return get_string (KEY_LAST_INPUT_CALCULUS); }
            set { set_string (KEY_LAST_INPUT_CALCULUS, value); }
        }

        public string last_input_calculus_x {
            owned get { return get_string (KEY_LAST_INPUT_CALCULUS_X); }
            set { set_string (KEY_LAST_INPUT_CALCULUS_X, value); }
        }

        public string last_input_calculus_upper_lim {
            owned get { return get_string (KEY_LAST_INPUT_CALCULUS_UPPER_LIM); }
            set { set_string (KEY_LAST_INPUT_CALCULUS_UPPER_LIM, value); }
        }

        public string last_input_calculus_lower_lim {
            owned get { return get_string (KEY_LAST_INPUT_CALCULUS_LOWER_LIM); }
            set { set_string (KEY_LAST_INPUT_CALCULUS_LOWER_LIM, value); }
        }

        public string[] last_input_graphing {
            owned get { return get_strv (KEY_LAST_INPUT_GRAPHING); }
            set { set_strv (KEY_LAST_INPUT_GRAPHING, value); }
        }

        public string date_diff_from {
            owned get { return get_string (KEY_DATE_DIFF_FROM); }
            set { set_string (KEY_DATE_DIFF_FROM, value); }
        }

        public string date_diff_to {
            owned get { return get_string (KEY_DATE_DIFF_TO); }
            set { set_string (KEY_DATE_DIFF_TO, value); }
        }

        public string date_starting_from {
            owned get { return get_string (KEY_DATE_STARTING_FROM); }
            set { set_string (KEY_DATE_STARTING_FROM, value); }
        }

        public int date_add_days {
            get { return get_int (KEY_DATE_ADD_DAYS); }
            set { set_int (KEY_DATE_ADD_DAYS, value); }
        }

        public int date_add_months {
            get { return get_int (KEY_DATE_ADD_MONTHS); }
            set { set_int (KEY_DATE_ADD_MONTHS, value); }
        }

        public int date_add_years {
            get { return get_int (KEY_DATE_ADD_YEARS); }
            set { set_int (KEY_DATE_ADD_YEARS, value); }
        }

        public bool diff_mode_dur {
            get { return get_boolean (KEY_DIFF_MODE_DUR); }
            set { set_boolean (KEY_DIFF_MODE_DUR, value); }
        }

        public bool date_find_mode {
            get { return get_boolean (KEY_DATE_FIND_MODE); }
            set { set_boolean (KEY_DATE_FIND_MODE, value); }
        }

        public string last_output_scientific {
            owned get { return get_string (KEY_LAST_OUTPUT_SCIENTIFIC); }
            set { set_string (KEY_LAST_OUTPUT_SCIENTIFIC, value); }
        }

        public string last_output_programmer {
            owned get { return get_string (KEY_LAST_OUTPUT_PROGRAMMER); }
            set { set_string (KEY_LAST_OUTPUT_PROGRAMMER, value); }
        }

        public string last_output_calculus {
            owned get { return get_string (KEY_LAST_OUTPUT_CALCULUS); }
            set { set_string (KEY_LAST_OUTPUT_CALCULUS, value); }
        }

        public string last_output_statistics {
            owned get { return get_string (KEY_LAST_OUTPUT_STATISTICS); }
            set { set_string (KEY_LAST_OUTPUT_STATISTICS, value); }
        }
    }
}
