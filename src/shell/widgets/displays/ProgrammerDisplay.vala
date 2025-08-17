namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/programmer_display.ui")]
    public class ProgrammerDisplay : Display {
        private bool _shift_on;
        public bool shift_on {
            get {
                return _shift_on;
            } set {
                _shift_on = value;
                shift_label.opacity = value ? 1 : 0.2;
            }
        }

        public string hex_number_value { get; set; default = "0"; }
        public string dec_number_value { get; set; default = "0"; }
        public string oct_number_value { get; set; default = "0"; }
        public string bin_number_value { get; set; default = "0"; }

        [GtkChild]
        private unowned Gtk.Label qwd_label;
        [GtkChild]
        private unowned Gtk.Label dwd_label;
        [GtkChild]
        private unowned Gtk.Label wrd_label;
        [GtkChild]
        private unowned Gtk.Label byt_label;

        [GtkChild]
        private unowned Gtk.Label bin_label;
        [GtkChild]
        private unowned Gtk.Label dec_label;
        [GtkChild]
        private unowned Gtk.Label hex_label;
        [GtkChild]
        private unowned Gtk.Label oct_label;

        [GtkChild]
        private unowned Gtk.Label shift_label;

        [GtkChild]
        private unowned Gtk.Entry main_entry;

        [GtkChild]
        private unowned Gtk.Label main_label;

        private NumberSystem _number_system;
        public NumberSystem number_system {
            get {
                return _number_system;
            }

            set {
                _number_system = value;
                bin_label.remove_css_class ("selected");
                dec_label.remove_css_class ("selected");
                hex_label.remove_css_class ("selected");
                oct_label.remove_css_class ("selected");

                switch (value) {
                    case BINARY:
                        bin_label.add_css_class ("selected");
                        break;
                    case DECIMAL:
                        dec_label.add_css_class ("selected");
                        break;
                    case HEXADECIMAL:
                        hex_label.add_css_class ("selected");
                        break;
                    case OCTAL:
                        oct_label.add_css_class ("selected");
                        break;
                }
            }
        }

        private GlobalWordLength _word_length;
        public GlobalWordLength word_length {
            get {
                return _word_length;
            }

            set {
                _word_length = value;
                qwd_label.opacity = 0.2;
                dwd_label.opacity = 0.2;
                wrd_label.opacity = 0.2;
                byt_label.opacity = 0.2;

                switch (value) {
                    case QWD:
                        qwd_label.opacity = 1;
                        break;
                    case DWD:
                        dwd_label.opacity = 1;
                        break;
                    case WRD:
                        wrd_label.opacity = 1;
                        break;
                    case BYT:
                        byt_label.opacity = 1;
                        break;
                }
            }
        }

        public bool collapsed { get; set; }

        private Pebbles.Settings settings;
        private unowned MainWindow window;
        private EntryFormatter entry_formatter;

        public signal void last_token_changed (bool[] bool_arr);

        construct {
            settings = Pebbles.Settings.get_default ();
            bin_number_value = get_binary_representation ();

            settings.changed["number-system"].connect ((key) => {
                number_system = settings.number_system;
            });

            number_system = settings.number_system;

            settings.changed["global-word-length"].connect ((key) => {
                word_length = settings.global_word_length;
            });

            word_length = settings.global_word_length;

            realize.connect (() => {
                window = (MainWindow) get_ancestor (typeof (MainWindow));
            });

            entry_formatter = new EntryFormatter (main_entry, ReplacementMode.PROGRAMMER);
            entry_formatter.on_input.connect (input_handler);
        }

        private string get_binary_representation () {
            string binary_value = "";
            int max_num = 0;
            switch (settings.global_word_length) {
                case GlobalWordLength.BYT:
                max_num = 8;
                break;
                case GlobalWordLength.WRD:
                max_num = 16;
                break;
                case GlobalWordLength.DWD:
                max_num = 32;
                break;
                case GlobalWordLength.QWD:
                max_num = 64;
                break;
            }

            for (int i = 0; i < max_num; i++) {
                binary_value += "0";
                if ((i + 1) % 8 == 0) {
                    binary_value += " ";
                }
            }

            return binary_value;
        }

        public void all_clear () {
            main_entry.grab_focus_without_selecting ();
            main_entry.set_text ("0");
            main_entry.set_position (1);
        }

        public void set_last_token_from_bit_grid (bool[] arr) {
            main_entry.set_text (window.on_programmer_set_last_token (
                arr, settings.global_word_length, settings.number_system));
            main_entry.set_position ((int) main_entry.text_length);
        }

        [GtkCallback]
        public void input () {
            on_input (main_entry.text);
        }

        public void show_result (string result) {
            if (result != "E") {
                add_css_class ("fade");
                Timeout.add (100, () => {
                    main_label.set_text (result);
                    remove_css_class ("fade");
                    return false;
                });
            } else {
                main_label.set_text (_("Error"));
                add_css_class ("shake");
                Timeout.add_once (400, () => {
                    remove_css_class ("shake");
                    main_entry.grab_focus_without_selecting ();
                });
            }
        }

        //  public void get_answer_evaluate (bool? dont_push_history = false) {
        //      if (!this.prog_view.window.history_manager.is_empty (EvaluationResult.ResultSource.PROG)) {
        //          bool[] last_output_array= this.prog_view.window.history_manager.get_last_evaluation_result (EvaluationResult.ResultSource.PROG).prog_output;
        //          string last_answer = programmer_calculator_front_end.bool_array_to_string (last_output_array, settings.global_word_length, settings.number_system);
        //          debug (last_answer);
        //          input_entry.set_text (input_entry.get_text().replace ("ans", last_answer));
        //          if (dont_push_history != true) {
        //              this.set_number_system ();
        //          }
        //      }
        //      string result = "";
        //      try {
        //          result = programmer_calculator_front_end.evaluate_exp (settings.global_word_length, settings.number_system, out answer_array);
        //          result = Utils.remove_leading_zeroes(result);
        //      } catch (CalcError e) {
        //          result = "E";
        //      }
        //      this.answer_label.set_text (result);
        //      if (result == "E") {
        //          shake ();
        //      }
        //      else {
        //          if (dont_push_history != true) {
        //              this.prog_view.window.history_manager.append_from_strings (EvaluationResult.ResultSource.PROG,
        //                                                                  input_entry.get_text (),
        //                                                                  result,
        //                                                                  null,
        //                                                                  null,
        //                                                                  0,
        //                                                                  0,
        //                                                                  0,
        //                                                                  programmer_calculator_front_end.get_token_array(),
        //                                                                  answer_array,
        //                                                                  settings.global_word_length,
        //                                                                  settings.number_system);
        //          }
        //          settings.prog_input_text = input_entry.get_text ();
        //          settings.prog_output_text = result;
        //      }
        //  }

        public void focus_entry () {
            main_entry.grab_focus_without_selecting ();
            main_entry.set_position (-1);
        }

        private void display_all_number_systems () {
            var parser = new Json.Parser ();
            try {
                parser.load_from_data (window.on_programmer_get_last_token (), -1);
                bin_number_value = get_binary_representation ();
                dec_number_value = "0";
                oct_number_value = "0";
                hex_number_value = "0";

                var root_object = parser.get_root ().get_object ();
                var current_number_system = (NumberSystem) root_object.get_int_member ("numberSystem");
                var token = root_object.get_string_member ("token");

                if (root_object.get_string_member ("tokenTypeS") == "operand") {
                    dec_number_value = window.on_programmer_convert_token (token, current_number_system, NumberSystem.DECIMAL, settings.global_word_length);
                    hex_number_value = window.on_programmer_convert_token (token, current_number_system, NumberSystem.HEXADECIMAL, settings.global_word_length);
                    oct_number_value = window.on_programmer_convert_token (token, current_number_system, NumberSystem.OCTAL, settings.global_word_length);
                    bin_number_value = window.on_programmer_convert_token (token, current_number_system, NumberSystem.BINARY, settings.global_word_length, true);

                    var bool_array_str = window.on_programmer_str_to_bool_arr (
                        token,
                        current_number_system,
                        settings.global_word_length
                    );

                    var bool_array = new bool[bool_array_str.length];
                    for (int i = 0; i < bool_array_str.length; i++) {
                        bool_array[i] = bool_array_str.get_char (i) == '1';
                    }

                    last_token_changed (bool_array);
                }
            } catch (Error e) {
                warning (e.message);
            }
        }

        //  [GtkCallback]
        protected bool input_handler (string full_expression, int input_length, string input_char) {
            if (full_expression.chug () != "") {
                window.on_programmer_populate_token_array (full_expression, number_system);
            }

            display_all_number_systems ();

            return Source.REMOVE;
        }
    }
}
