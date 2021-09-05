/*-
 * Copyright (c) 2017-2020 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright (c) 2017-2020 Saunak Biswas <saunakbis97@gmail.com>
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
        Gtk.CssProvider font_size_provider;
        const string DISPLAY_FONT_SIZE_TEMPLATE = 
        "
        .pebbles_h1 { font-size: %dpx; } 
        .pebbles_h2 { font-size: %dpx; }
        .pebbles_h4 { font-size: %dpx; }
        ";

        public PebblesApp () {
            Object (
                application_id: "com.github.subhadeepjasu.pebbles",
                flags: ApplicationFlags.HANDLES_COMMAND_LINE
            );
            X.init_threads ();
            settings = Settings.get_default ();

            Timeout.add_seconds (1, () => {
                if (this.get_active_window () != null) {
                    int height = this.get_active_window ().get_allocated_height ();
                    if (((MainWindow) (this.get_active_window ())).previous_height != height) {
                        ((MainWindow) (this.get_active_window ())).previous_height = height;
                        adjust_font_responsive (height);
                    }
                    return true;
                }
                return false;
            });
        }

        protected override void activate () {
            init_theme ();
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
            option [0] = { "mini_mode", 0, 0, OptionArg.NONE, ref mini_mode, _("Open In Mini Mode"), null };
            option [1] = { "new_window", 0, 0, OptionArg.NONE, ref new_window, _("Open A New Window"), null };
            option [2] = { "test", 0, 0, OptionArg.NONE, ref test_mode, _("Enable test mode"), null };
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
                css_provider.load_from_resource ("/com/github/subhadeepjasu/pebbles/Application.css");
                // CSS Provider
                Gtk.StyleContext.add_provider_for_screen (
                    Gdk.Screen.get_default(),
                    css_provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );
            }
            font_size_provider = new Gtk.CssProvider ();
            Gtk.StyleContext.add_provider_for_screen (
                Gdk.Screen.get_default(),
                font_size_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
            if (mini_mode) {
                init_theme ();
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
        private double map_range (double input, double input_start, double input_end, double output_start, double output_end) {
            return output_start + ((output_end - output_start) / (input_end - input_start)) * (input - input_start);
        }
        private void adjust_font_responsive (int height) {
            try {
                var target_size_h1 = (int)map_range (double.max((double) height/600, 1), 1, 2, 40, 120);
                var target_size_h2 = (int)map_range (double.max((double) height/600, 1), 1, 2, 20, 50);
                var target_size_h4 = (int)map_range (double.max((double) height/600, 1), 1, 2, 10, 20);
                var css = DISPLAY_FONT_SIZE_TEMPLATE.printf(target_size_h1, target_size_h2, target_size_h4);
                font_size_provider.load_from_data (css, -1);
            } catch (Error e) {
                Process.exit(1);
            }
        }

        private void init_theme () {
            GLib.Value value = GLib.Value (GLib.Type.STRING);
            Gtk.Settings.get_default ().get_property ("gtk-theme-name", ref value);
            if (!value.get_string ().has_prefix ("io.elementary.")) {
                Gtk.Settings.get_default ().set_property ("gtk-icon-theme-name", "elementary");
                Gtk.Settings.get_default ().set_property ("gtk-theme-name", "io.elementary.stylesheet.blueberry");
            }
        }

        public static int main (string[] args) {
            var app = new PebblesApp ();
            return app.run (args);
        }
    }
}
