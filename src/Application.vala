/*-
 * Copyright (c) 2017-2018 Subhadeep Jasu <subhajasu@gmail.com>
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
 *              Saunak Biswas  <saunakbis97@gmail.com>
 */

namespace Pebbles {
    public class PebblesApp : Gtk.Application {
        Pebbles.Settings settings;
        private bool test_mode = false;

        static PebblesApp _instance = null;
        public static PebblesApp instance {
            get {
                if (_instance == null) {
                    _instance = new PebblesApp ();
                }
                return _instance;
            }
        }

        Gtk.CssProvider css_provider;

        public PebblesApp () {
            Object (
                application_id: "com.github.SubhadeepJasu.pebbles",
                flags: ApplicationFlags.HANDLES_COMMAND_LINE
            );
            X.init_threads ();
            settings = Settings.get_default ();
        }

        protected override void activate () {
            var mainwindow = new MainWindow ();
            mainwindow.application = this;
            
            mainwindow.present ();
        }

        public override int command_line (ApplicationCommandLine cmd) {
            command_line_interpreter (cmd);
            return 0;
        }

        private void command_line_interpreter (ApplicationCommandLine cmd) {
            string[] cmd_args = cmd.get_arguments ();
            unowned string[] args = cmd_args;
            
            bool new_window = false, mini_mode = false;
            
            GLib.OptionEntry [] option = new OptionEntry [4];
            option [0] = { "mini_mode", 0, 0, OptionArg.NONE, ref mini_mode, "Open In Mini Mode", null };
            option [1] = { "new_window", 0, 0, OptionArg.NONE, ref new_window, "Open A New Window", null };
            option [2] = { "test", 0, 0, OptionArg.NONE, ref test_mode, "Enable test mode", null };
            option [3] = { null };
            
            var option_context = new OptionContext ("actions");
            option_context.add_main_entries (option, null);
            try {
                option_context.parse (ref args);
            } catch (Error err) {
                warning (err.message);
                return;
            }

            if (css_provider == null) {
                css_provider = new Gtk.CssProvider();
                try {
                    css_provider.load_from_resource ("/com/github/SubhadeepJasu/pebbles/Application.css");
                }
                catch (Error e) {
                    warning("%s", e.message);
                }
                // CSS Provider
                Gtk.StyleContext.add_provider_for_screen (
                    Gdk.Screen.get_default(),
                    css_provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );
            }
            
            if (mini_mode) {
                var minicalcwindow = new Pebbles.MiniCalculator ();
                minicalcwindow.show_all ();
                minicalcwindow.application = this;
                add_window (minicalcwindow);
            }
            else if (test_mode) {
                TestUtil.run_test ();
                return;
            }
            else {
                activate ();
            }
        }

        public static int main (string[] args) {
            var app = new PebblesApp ();
            return app.run (args);
        }
    }
}
