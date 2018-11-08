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

        public PebblesApp () {
            Object (
                application_id: "com.github.SubhadeepJasu.pebbles",
                flags: ApplicationFlags.HANDLES_COMMAND_LINE
            );
            settings = Settings.get_default ();
        }

        public MainWindow mainwindow { get; private set; default = null; }
        protected override void activate () {
            if (mainwindow == null) {
                mainwindow = new MainWindow ();
                mainwindow.application = this;
            }
            var css_provider = new Gtk.CssProvider();
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
            mainwindow.present ();
        }

        public override int command_line (ApplicationCommandLine cmd) {
            command_line_interpreter (cmd);
            return 0;
        }

        private void command_line_interpreter (ApplicationCommandLine cmd) {
            string[] cmd_args = cmd.get_arguments ();
            unowned string[] args = cmd_args;
            
            bool mem_to_clip = false;
            
            GLib.OptionEntry [] option = new OptionEntry [3];
            option [0] = { "last_result", 0, 0, OptionArg.NONE, ref mem_to_clip, "Get last answer", null };
            option [1] = { "test", 0, 0, OptionArg.NONE, ref test_mode, "Enable test mode", null };
            option [2] = { null };
            
            var option_context = new OptionContext ("actions");
            option_context.add_main_entries (option, null);
            try {
                option_context.parse (ref args);
            } catch (Error err) {
                warning (err.message);
                return;
            }
            
            if (mem_to_clip && !test_mode) {
                if (mainwindow != null) {
                    mainwindow.answer_notify ();
                    message ("Last answer copied to clipboard.");
                }
                else if (mainwindow == null) {
                    error ("Action ignored. App UI not running");
                }
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
