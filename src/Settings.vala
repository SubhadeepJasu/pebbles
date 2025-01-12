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

        public string version {
            owned get { return get_string ("version"); }
            set { set_string ("version", value); }
        }

        public bool load_last_session {
            get { return get_boolean ("load-last-session"); }
            set { set_boolean ("load-last-session", value); }
        }

        public string theme {
            owned get { return get_string ("theme"); }
            set { set_string ("theme", value); }
        }

        public int view_index {
            get { return get_int ("view-index"); }
            set { set_int ("view-index", value); }
        }

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

        public string forex_api_key {
            owned get { return get_string ("forex-api-key"); }
            set { set_string ("forex-api-key", value); }
        }
    }
}
