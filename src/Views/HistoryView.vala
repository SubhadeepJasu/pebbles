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
        Gtk.Button clear_button;

        EvaluationResult.ResultSource source;

        public signal void select_eval_result (EvaluationResult result);
        public signal void insert_eval_result (EvaluationResult result);
        public signal void clear ();

        public HistoryView (HistoryManager history, EvaluationResult.ResultSource result_source) {
            
            this.history = history;
            this.source = result_source;
            
            make_ui ();
            for (int i = 0; i < history.length (); i++) {
                //if (history.get_nth_evaluation_result(i).result_source == this.source) {
                    append_to_view (history.get_nth_evaluation_result (i));
                //}
            }

            make_events ();
        }

        void make_ui () {
            main_tree = new Gtk.TreeView ();
            setup_treeview (main_tree);
            main_tree.set_hover_selection (true);
            main_tree.tooltip_text = _("Double click to recall, Right click to insert");
            var scrolled_window = new Gtk.ScrolledWindow (null, null);
            scrolled_window.add (main_tree);
            scrolled_window.width_request = 600;
            scrolled_window.height_request = 400;

            clear_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            clear_button.tooltip_text = _("Clear history");

            var headerbar = new Gtk.HeaderBar ();
            headerbar.has_subtitle = false;
            headerbar.set_show_close_button (true);
            headerbar.pack_end(clear_button);
            headerbar.title = _("History");

            set_titlebar (headerbar);

            // Set up window attributes
            this.set_default_size (600, 400);
            this.set_size_request (600, 400);

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
            view.insert_column_with_attributes (-1, (_("Input Expression") + "\x20 \x20 \x20 \x20 \x20 \x20 \x20"), new Gtk.CellRendererText (), "text", i++);
            view.insert_column_with_attributes (-1, (_("Type")), new Gtk.CellRendererText (),  "text", i++);
            view.insert_column_with_attributes (-1, (_("Mode")), new Gtk.CellRendererText (), "text", i++);
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
                word_length = "Qword";
                break;
                case GlobalWordLength.DWD:
                word_length = "Dword";
                break;
                case GlobalWordLength.WRD:
                word_length = "Word";
                break;
                case GlobalWordLength.BYT:
                word_length = "Byte";
                break;
                default:
                word_length = "N / A";
                break;
            }
            if (result.result_source == EvaluationResult.ResultSource.SCIF) {
                listmodel.set (iter, 0, result.problem_expression,
                                     1, angle_mode,
                                     2, _("Scientific"),
                                     3, result.result.to_string ());
            } else if (result.result_source == EvaluationResult.ResultSource.CALC) {
                string problem_function = "";
                if (result.calc_mode == EvaluationResult.CalculusResultMode.INT) {
                    problem_function = "\xE2\x88\xAB" + " \xE2\x82\x8D" + "\xE2\x82\x98 \xE2\x82\x8C " + result.int_limit_a.to_string () + ", \xE2\x82\x99 \xE2\x82\x8C " + result.int_limit_b.to_string () + "\xE2\x82\x8E";
                } else if (result.calc_mode == EvaluationResult.CalculusResultMode.DER) {
                    string derivative_limit = "\xE2\x82\x8D"  + "\xE2\x82\x93" + "\xE2\x82\x8C" + result.derivative_point.to_string ();
                    problem_function = "d/dx | " + derivative_limit + "\xE2\x82\x8E";
                }
                problem_function = problem_function.replace("0", "\xE2\x82\x80");
                problem_function = problem_function.replace("1", "\xE2\x82\x81");
                problem_function = problem_function.replace("2", "\xE2\x82\x82");
                problem_function = problem_function.replace("3", "\xE2\x82\x83");
                problem_function = problem_function.replace("4", "\xE2\x82\x84");
                problem_function = problem_function.replace("5", "\xE2\x82\x85");
                problem_function = problem_function.replace("6", "\xE2\x82\x86");
                problem_function = problem_function.replace("7", "\xE2\x82\x87");
                problem_function = problem_function.replace("8", "\xE2\x82\x88");
                problem_function = problem_function.replace("9", "\xE2\x82\x89");
                problem_function = problem_function.replace("-", "\xE2\x82\x8B");
                
                listmodel.set (iter, 0, problem_function + "\t" + result.problem_expression,
                                     1, angle_mode, 
                                     2, _("Calculus"),
                                     3, result.result.to_string ());
            } else {
                listmodel.set (iter, 0, result.problem_expression,
                                     1, word_length,
                                     2, _("Programmer"),
                                     3, result.result.to_string ());
            }
            show_all ();
        }

        private void make_events () {
            main_tree.row_activated.connect ((path, column) => {
                var result = history.get_nth_evaluation_result (path.get_indices ()[0]);
                select_eval_result (result);
            });
            main_tree.button_press_event.connect ((event) => {
                if (event.type == Gdk.EventType.BUTTON_PRESS && event.button == 3) {
                    Gtk.TreePath path;
                    Gtk.TreeViewColumn column;
                    main_tree.get_cursor (out path, out column);
                    var result = history.get_nth_evaluation_result (path.get_indices ()[0]);
                    insert_eval_result (result);
                }
                return false;
            });
            this.key_release_event.connect ((event) => {
                if (event.keyval == KeyboardHandler.KeyMap.ESCAPE) {
                    this.hide ();
                }
                return false;
            });
            clear_button.clicked.connect(() => {
                clear();
            });
        }
    }
}
