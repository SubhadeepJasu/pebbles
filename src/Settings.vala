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

        public string theme {
            owned get { return get_string ("theme"); }
            set { set_string ("theme", value); }
        }
    }
}
