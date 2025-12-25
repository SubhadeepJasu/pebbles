// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    public class Application : Gtk.Application {
        public bool debug { get; construct set; default = false; }
        public Pebbles.Settings settings { get; protected set; }

        private List<MainWindow> main_windows;

        protected signal MainWindow create_window_request ();

        construct {
            this.version = Config.VERSION;
            main_windows = new List<MainWindow> ();
            set_accels_for_action (Actions.PREFIX + Actions.CONTROLS, {"F1"});
            set_accels_for_action (Actions.PREFIX + Actions.PREFERENCES, {"F2"});
            set_accels_for_action (Actions.PREFIX + Actions.COPY, {"<Ctrl>C"});
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

        public override int command_line (ApplicationCommandLine cmd) {
            //  command_line_interpreter (cmd);
            activate ();
            return 0;
        }

        public MainWindow create_main_window () {
            MainWindow window = create_window_request ();
            main_windows.append (window);
            window.present ();
            return window;
        }
    }
}
