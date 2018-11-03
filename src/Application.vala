/*-
 * Copyright (c) 2017-2018 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 *              Saunak Biswas  <saunakbis97@gmail.com>
 */
 
namespace Pebbles {
    public class PebblesApp : Gtk.Application {
        
        Pebbles.Settings settings;
        public PebblesApp () {
            Object (
                application_id: "com.github.SubhadeepJasu.pebbles",
                flags: ApplicationFlags.FLAGS_NONE
            );
            settings = Settings.get_default ();
        }

        [CCode (array_length = false, array_null_terminated = true)]
        string[] ? arg_files = null;

        public MainWindow mainwindow { get; private set; default = null; }
        protected override void activate () {
            if (mainwindow == null) {
                mainwindow = new MainWindow ();
                mainwindow.application = this;
            }
            mainwindow.present ();
        }
        
        

        public static int main (string[] args) {
            var app = new PebblesApp ();
            return app.run (args);
        }
    }
}
