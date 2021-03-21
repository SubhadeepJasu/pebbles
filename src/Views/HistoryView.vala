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
    public class HistoryView : Gtk.Window {
        Gtk.TreeView main_tree;
        Gtk.ListStore listmodel;
        Gtk.TreeIter iter;
        HistoryManager history;

        EvaluationResult.ResultSource source;

        public signal void select_eval_result (EvaluationResult result);

        public HistoryView (HistoryManager history, EvaluationResult.ResultSource result_source) {
            
            this.history = history;
            this.source = result_source;
            
            make_ui ();
            for (int i = 0; i < history.length (); i++) {
                if (history.get_nth_evaluation_result(i).result_source == this.source) {
                    append_to_view (history.get_nth_evaluation_result (i));
                }
            }

            make_events ();
        }

        void make_ui () {
            main_tree = new Gtk.TreeView ();
            setup_treeview (main_tree);
            main_tree.set_hover_selection (true);
            main_tree.tooltip_text = _("Double click to recall");
            var scrolled_window = new Gtk.ScrolledWindow (null, null);
            scrolled_window.add (main_tree);
            scrolled_window.width_request = 880;
            scrolled_window.height_request = 400;

            var headerbar = new Gtk.HeaderBar ();
            headerbar.has_subtitle = false;
            headerbar.set_show_close_button (true);
            headerbar.title = _("History");

            set_titlebar (headerbar);

            // Set up window attributes
            this.set_default_size (880, 400);
            this.set_size_request (880, 400);

            this.add (scrolled_window);

            this.destroy_with_parent = true;
            this.modal = true;
            show_all ();
        }

        private void setup_treeview (Gtk.TreeView view) {
            listmodel = new Gtk.ListStore (7, typeof (string), typeof (string), typeof (string), 
                                            typeof (string), typeof (string),
                                            typeof (string), typeof (string));
            view.set_model (listmodel);
            int i = 0;
            view.insert_column_with_attributes (-1, (_("Input Expression")), new Gtk.CellRendererText (), "text", i++);
            if (source != EvaluationResult.ResultSource.PROG) {
                view.insert_column_with_attributes (-1, (_("Angle Mode")), new Gtk.CellRendererText (), "text", i++);
            }
            if (source == EvaluationResult.ResultSource.CALC) {
                view.insert_column_with_attributes (-1, (_("Calculus Mode")), new Gtk.CellRendererText (), "text", i++);
                view.insert_column_with_attributes (-1, (_("Integral Upper Limit")), new Gtk.CellRendererText (), "text", i++);
                view.insert_column_with_attributes (-1, (_("Integral Lower Limit")), new Gtk.CellRendererText (), "text", i++);
                view.insert_column_with_attributes (-1, (_("Derivative At Point")), new Gtk.CellRendererText (),  "text", i++);
            }
            if (source == EvaluationResult.ResultSource.PROG) {
                view.insert_column_with_attributes (-1, (_("Word Length")), new Gtk.CellRendererText (),  "text", i++);
            }
            view.insert_column_with_attributes (-1, (_("Result")), new Gtk.CellRendererText (), "text", i);
        }

        private void append_to_view (EvaluationResult result) {
            listmodel.append (out iter);

            string angle_mode = "";
            switch (result.angle_mode) {
                case GlobalAngleUnit.DEG:
                angle_mode = _("Degree");
                break;
                case GlobalAngleUnit.RAD:
                angle_mode = _("Radian");
                break;
                case GlobalAngleUnit.GRAD:
                angle_mode = _("Gradian");
                break;
                default:
                angle_mode = "N / A";
                break;
            }

            string calc_result_type = "";
            switch (result.calc_mode) {
                case EvaluationResult.CalculusResultMode.INT:
                calc_result_type = _("Integral");
                break;
                case EvaluationResult.CalculusResultMode.DER:
                calc_result_type = _("Derivative");
                break;
                default:
                calc_result_type = "N / A";
                break;
            }
            string word_length = "";
            switch (result.word_length) {
                case GlobalWordLength.QWD:
                word_length = "QWORD";
                break;
                case GlobalWordLength.DWD:
                word_length = "DWORD";
                break;
                case GlobalWordLength.WRD:
                word_length = "WORD";
                break;
                case GlobalWordLength.BYT:
                word_length = "BYTE";
                break;
                default:
                word_length = "N / A";
                break;
            }
            if (source == EvaluationResult.ResultSource.SCIF) {
                listmodel.set (iter, 0, result.problem_expression,
                                     1, angle_mode,
                                     2, result.result.to_string ());
            } else if (source == EvaluationResult.ResultSource.CALC) {
                listmodel.set (iter, 0, result.problem_expression,
                                     1, angle_mode, 
                                     2, calc_result_type, 
                                     3, result.int_limit_a.to_string (),
                                     4, result.int_limit_b.to_string (),
                                     5, result.derivative_point.to_string (),
                                     6, result.result.to_string ());
            } else {
                listmodel.set (iter, 0, result.problem_expression,
                                     1, word_length,
                                     2, result.result.to_string ());
            }
            show_all ();
        }

        private void make_events () {
            main_tree.row_activated.connect ((path, column) => {
                var result = history.get_nth_evaluation_result (path.get_indices ()[0]);
                select_eval_result (result);
            });

            this.key_release_event.connect ((event) => {
                if (event.keyval == KeyboardHandler.KeyMap.ESCAPE) {
                    this.hide ();
                }
                return false;
            });
        }
    }
}