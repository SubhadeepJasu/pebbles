// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    public class Application : Adw.Application {
        public bool debug { get; construct set; default = false; }
        public GLib.Settings settings { get; protected set; }

        construct {
            // this.version = Config.VERSION;


        }

        /**
          * Setup the application.
          */
        public override void startup () {
            base.startup ();


        }

        /**
          * Activate the application.
          */
        public override void activate () {
            base.activate ();
            // create_main_window ();
        }
    }
}
