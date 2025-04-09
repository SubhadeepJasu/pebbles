namespace Pebbles {
    public class EntryFormatter {
        public unowned Gtk.Entry main_entry;
        public bool polar_mode;
        private bool auto_entry;
        public bool disabled { get; set; }

        public EntryFormatter (Gtk.Entry entry) {
            this.main_entry = entry;

            // TODO: Do token check before inserting any character
            main_entry.get_delegate ().insert_text.connect_after ((ch, length) => {
                if (auto_entry || disabled) {
                    return;
                }

                var text = main_entry.text;
                Idle.add (() => {
                    if (text.length > 1 && text.has_prefix ("0")) {
                        main_entry.text = text.substring (1);
                        main_entry.set_position (1);
                        return Source.REMOVE;
                    }

                    if (length > 1) {
                        return Source.REMOVE;
                    }

                    Idle.add (() => {
                        if (main_entry.text_length >= 1 && main_entry.text != "0")
                            replace_inserted_character (
                                main_entry.text,
                                main_entry.text_length,
                                main_entry.get_position (),
                                polar_mode
                            );
                        return Source.REMOVE;
                    });
                    return Source.REMOVE;
                });
            });

            main_entry.get_delegate ().delete_text.connect_after (() => {
                if (disabled) {
                    return;
                }

                Idle.add (() => {
                    if (main_entry.text_length == 0) {
                        main_entry.text = "0";
                        main_entry.set_position ((int) main_entry.text_length);
                    }

                    return Source.REMOVE;
                });
            });
        }

        public void replace_inserted_character (
            string text, uint text_length, int caret_pos, bool radial_mode = false) {
            var symbols = split_utf8 (text, text_length);
            var current_symbol = symbols[caret_pos];
            if (current_symbol == null) {
                return;
            }
            var previous_symbol = "";
            var previous_caret_pos = caret_pos - 1;
            for (int i = caret_pos - 1; i >= 0; i--) {
                if (symbols[i] != " ") {
                    previous_symbol = symbols[i];
                    previous_caret_pos = i;
                    break;
                }
            }

            //  print ("%s, %s\n", previous_symbol, current_symbol);

            bool double_replaced;
            int len_gain;
            var replacement = find_replacement (
                current_symbol, previous_symbol, radial_mode, out double_replaced, out len_gain);
            symbols[caret_pos] = replacement;
            if (double_replaced) {
                symbols[previous_caret_pos] = "";
                if (previous_caret_pos > 0 && symbols[previous_caret_pos - 1] == " ") {
                    symbols[previous_caret_pos - 1] = "";
                }

                if (previous_caret_pos < text_length - 1 && symbols[previous_caret_pos + 1] == " ") {
                    symbols[previous_caret_pos + 1] = "";
                }
            }

            auto_entry = true;
            main_entry.text = string.joinv ("", symbols);
            if (double_replaced) {
                main_entry.set_position (caret_pos - 1);
            } else {
                main_entry.set_position (caret_pos + len_gain);
            }
            auto_entry = false;
        }

        private string[] split_utf8 (string text, uint text_length) {
            var result = new string[text_length + 1];
            var j = 0;

            var sb = new StringBuilder ();
            for (int i = 0; i <= text.length; i++) {
                if ((text[i] & 0xC0) != 0x80) { // Prevent commiting if its a continuation bit
                    result[j++] = sb.str + "";
                    sb.erase (0, sb.len);
                }

                if (text[i] != '\0') {
                    sb.append_c (text[i]);
                }
            }

            return result;
        }

        public string find_replacement (
            string current_symbol,
            string previous_symbol,
            bool radial_mode,
            out bool double_replaced,
            out int len_gain
        ) {
            double_replaced = false;
            switch (current_symbol) {
                case "x":
                    len_gain = 0;
                    if (radial_mode) {
                        return "θ";
                    } else {
                        return "x";
                    }
                case "+":
                    len_gain = 2;
                    return " + ";
                case "−":
                case "-":
                    len_gain = 2;
                    return " − ";
                case "÷":
                case "/":
                    len_gain = 2;
                    return " ÷ ";
                case "×":
                case "*":
                    len_gain = 2;
                    if (previous_symbol == "×") {
                        double_replaced = true;
                        return " ^ ";
                    }

                    return " × ";
                case "s":
                    len_gain = 3;
                    return "sin ";
                case "S":
                    len_gain = 4;
                    return "isin ";
                case "h":
                    len_gain = 4;
                    return "sinh ";
                case "H":
                    len_gain = 5;
                    return "isinh ";
                case "c":
                    len_gain = 3;
                    return "cos ";
                case "C":
                    len_gain = 4;
                    return "icos ";
                case "o":
                    len_gain = 4;
                    return "cosh ";
                case "O":
                    len_gain = 5;
                    return "icosh ";
                case "t":
                    len_gain = 3;
                    return "tan ";
                case "T":
                    len_gain = 4;
                    return "itan ";
                case "a":
                    len_gain = 4;
                    return "tanh ";
                case "A":
                    len_gain = 5;
                    return "itanh ";
                case "q":
                    len_gain = 2;
                    return " ^ ";
                case "Q":
                    len_gain = 0;
                    return "√";
                case "z":
                    len_gain = 5;
                    return "10 ^ ";
                case "Z":
                    len_gain = 3;
                    return "e ^ ";
                case "F":
                case "f":
                    len_gain = 0;
                    return "!";
                case "m":
                    len_gain = 4;
                    return " mod ";
                case "M":
                    len_gain = 4;
                    return " log ";
                case "l":
                    len_gain = 5;
                    return "10 log ";
                case "L":
                    len_gain = 5;
                    return "ln ";
                default:
                    len_gain = 0;
                    return current_symbol;
            }
        }
    }
}
