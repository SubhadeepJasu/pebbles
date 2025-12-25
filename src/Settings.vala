/*
 * Copyright 2019-2025 Subhadeep Jasu <subhadeep107@proton.me>
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

        public Settings (string schema_id) {
            Object (
                schema_id: schema_id
            );
        }

        public void reset_all () {
            List<string> keys = new List<string> ();
            keys.append ("global-angle-unit");
            keys.append ("global-word-length");
            keys.append ("number-system");

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
                keys.append (item + "-from");
                keys.append (item + "-from-unit");
                keys.append (item + "-to-unit");
            }

            foreach (var item in keys) {
                reset (item);
            }
        }

        public string version {
            owned get { return get_string ("version"); }
            set { set_string ("version", value); }
        }

        public bool load_last_session {
            get { return get_boolean ("load-last-session"); }
            set { set_boolean ("load-last-session", value); }
        }

        public bool result_flow {
            get { return get_boolean ("result-flow"); }
            set { set_boolean ("result-flow", value); }
        }

        public string theme {
            owned get { return get_string ("theme"); }
            set { set_string ("theme", value); }
        }

        public ConstantKeyIndex constant_key_value1 {
            get { return get_enum ("constant-key-value1"); }
            set { set_enum ("constant-key-value1", value); }
        }

        public ConstantKeyIndex constant_key_value2 {
            get { return get_enum ("constant-key-value2"); }
            set { set_enum ("constant-key-value2", value); }
        }

        public uint decimal_places {
            get { return get_uint ("decimal-places"); }
            set { set_uint ("decimal-places", value); }
        }

        public bool use_exponential_form {
            get { return get_boolean ("use-exponential-form"); }
            set { set_boolean ("use-exponential-form", value); }
        }

        public uint integration_resolution {
            get { return get_uint ("integration-resolution"); }
            set { set_uint ("integration-resolution", value); }
        }

        public uint derivative_accuracy {
            get { return get_uint ("derivative-accuracy"); }
            set { set_uint ("derivative-accuracy", value); }
        }

        public string forex_api_key {
            owned get { return get_string ("forex-api-key"); }
            set { set_string ("forex-api-key", value); }
        }

        public uint forex_api_last_updated {
            get { return get_uint ("forex-timestamp"); }
            set { set_uint ("forex-timestamp", value); }
        }

        public string[] forex_rates_cache {
            owned get { return get_strv ("forex-rates-cache"); }
            set { set_strv ("forex-rates-cache", value); }
        }

        // State Saving
        public GlobalAngleUnit global_angle_unit {
            get { return get_enum ("global-angle-unit"); }
            set { set_enum ("global-angle-unit", value); }
        }

        public GlobalWordLength global_word_length {
            get { return get_enum ("global-word-length"); }
            set { set_enum ("global-word-length", value); }
        }

        public NumberSystem number_system {
            get { return get_enum ("number-system"); }
            set { set_enum ("number-system", value); }
        }

        public string last_input_scientific {
            owned get { return get_string ("last-input-scientific"); }
            set { set_string ("last-input-scientific", value); }
        }

        public string last_input_programmer {
            owned get { return get_string ("last-input-programmer"); }
            set { set_string ("last-input-programmer", value); }
        }

        public string last_input_calculus {
            owned get { return get_string ("last-input-calculus"); }
            set { set_string ("last-input-calculus", value); }
        }
    }
}
