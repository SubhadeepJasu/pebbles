// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    public class Application : Gtk.Application {
        public bool debug { get; construct set; default = false; }
        public Pebbles.Settings settings { get; protected set; }

        private List<Window> main_windows;

        protected signal Window create_window_request ();

        construct {
            this.version = Config.VERSION;
            main_windows = new List<Window> ();
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
            create_main_window ();
        }

        public Window create_main_window () {
            Window window = create_window_request ();
            main_windows.append (window);
            window.present ();
            return window;
        }
    }
}
