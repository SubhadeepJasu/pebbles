// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    public class Application : Gtk.Application {
        public bool debug { get; construct set; default = false; }
        public GLib.Settings settings { get; protected set; }

        private Gee.List<Window> main_windows;

        protected signal Window create_window_request ();

        construct {
            this.version = Config.VERSION;


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
            print ("hello\n");
            Window window = create_window_request ();
            print ("hello2\n");
            if (window == null) {
                print ("Error\n");
            }
            main_windows.add (window);
            window.present ();
            return window;
        }
    }
}
