/*-
 * Copyright (c) 2017-2019 Subhadeep Jasu <subhajasu@gmail.com>
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
    public class HistoryView : Gtk.Window {
        Gtk.ListStore listmodel;
        Gtk.TreeIter iter;

        public HistoryView (HistoryManager history) {
            make_ui ();
            

            for (int i = 0; i < history.length (); i++) {
                append_to_view (history.get_nth_evaluation_result (i));
            }
        }

        void make_ui () {
            var main_grid = new Gtk.Grid ();

            var main_tree = new Gtk.TreeView ();
            setup_treeview (main_tree);

            var headerbar = new Gtk.HeaderBar ();
            headerbar.has_subtitle = false;
            headerbar.set_show_close_button (true);
            headerbar.title = "History";

            set_titlebar (headerbar);

            // Set up window attributes
            this.resizable = false;
            this.set_default_size (640, 480);
            this.set_size_request (640, 480);

            this.add (main_tree);

            this.destroy_with_parent = true;
            this.modal = true;
            show_all ();
        }

        private void setup_treeview (Gtk.TreeView view) {
            listmodel = new Gtk.ListStore (7, typeof (string), typeof (string), typeof (string), 
                                            typeof (string), typeof (string),
                                            typeof (string), typeof (string));
            view.set_model (listmodel);
            view.insert_column_with_attributes (-1, "Input Expression", new Gtk.CellRendererText (), "text", 0);
            view.insert_column_with_attributes (-1, "Angle Mode", new Gtk.CellRendererText (), "text", 1);
            view.insert_column_with_attributes (-1, "Calculus Result Type", new Gtk.CellRendererText (), "text", 2);
            view.insert_column_with_attributes (-1, "Integral Upper Limit", new Gtk.CellRendererText (), "text", 3);
            view.insert_column_with_attributes (-1, "Integral Lower Limit", new Gtk.CellRendererText (), "text", 4);
            view.insert_column_with_attributes (-1, "Derivative At Point", new Gtk.CellRendererText (),  "text", 5);
            view.insert_column_with_attributes (-1, "Result", new Gtk.CellRendererText (), "text", 6);
        }

        private void append_to_view (EvaluationResult result) {
            listmodel.append (out iter);

            string angle_mode = "";
            switch (result.angle_mode) {
                case GlobalAngleUnit.DEG:
                angle_mode = "Degree";
                break;
                case GlobalAngleUnit.RAD:
                angle_mode = "Radian";
                break;
                case GlobalAngleUnit.GRAD:
                angle_mode = "Gradian";
                break;
                default:
                angle_mode = "N / A";
                break;
            }

            string calc_result_type = "";
            switch (result.calc_mode) {
                case EvaluationResult.CalculusResultMode.INT:
                calc_result_type = "Integral";
                break;
                case EvaluationResult.CalculusResultMode.DER:
                calc_result_type = "Derivative";
                break;
                default:
                calc_result_type = "N / A";
                break;
            }
            listmodel.set (iter, 0, result.problem_expression,
                                 1, angle_mode, 
                                 2, calc_result_type, 
                                 3, result.int_limit_a.to_string (),
                                 4, result.int_limit_b.to_string (),
                                 5, result.derivative_point.to_string (),
                                 6, result.result.to_string ());
            show_all ();
        }
    }
}