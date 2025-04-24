namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/programmer_display.ui")]
    public class ProgrammerDisplay : Display {
        public string hex_number_value { get; set; default = "0"; }
        public string dec_number_value { get; set; default = "0"; }
        public string oct_number_value { get; set; default = "0"; }
        public string bin_number_value { get; set; default = "0"; }

        public bool collapsed { get; set; }

        private Pebbles.Settings settings;
        construct {
            settings = Pebbles.Settings.get_default ();
            bin_number_value = get_binary_representation ();
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
    }
}
