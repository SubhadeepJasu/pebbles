namespace Pebbles {
    public class EntryFormatter {
        // Modular replacement rules for scientific mode
        private const string replacement_rules_scientific = """
        {
            "x": {"radial": "θ", "default": "x", "len_gain": 0},
            "+": {"default": " + ", "len_gain": 2},
            "−": {"default": " − ", "len_gain": 2},
            "-": {"default": " − ", "len_gain": 2},
            "÷": {"default": " ÷ ", "len_gain": 2},
            "/": {"default": " ÷ ", "len_gain": 2},
            "×": {"default": " × ", "len_gain": 2, "double": " ^ "},
            "*": {"default": " × ", "len_gain": 2, "double": " ^ "},
            "s": {"default": "sin ", "len_gain": 3},
            "S": {"default": "isin ", "len_gain": 4},
            "h": {"default": "sinh ", "len_gain": 4},
            "H": {"default": "isinh ", "len_gain": 5},
            "c": {"default": "cos ", "len_gain": 3},
            "C": {"default": "icos ", "len_gain": 4},
            "o": {"default": "cosh ", "len_gain": 4},
            "O": {"default": "icosh ", "len_gain": 5},
            "t": {"default": "tan ", "len_gain": 3},
            "T": {"default": "itan ", "len_gain": 4},
            "a": {"default": "tanh ", "len_gain": 4},
            "A": {"default": "itanh ", "len_gain": 5},
            "q": {"default": " ^ ", "len_gain": 2},
            "Q": {"default": "√", "len_gain": 0},
            "z": {"default": "10 ^ ", "len_gain": 5},
            "Z": {"default": "e ^ ", "len_gain": 3},
            "F": {"default": "!", "len_gain": 0},
            "f": {"default": "!", "len_gain": 0},
            "m": {"default": " mod ", "len_gain": 4},
            "M": {"default": " log ", "len_gain": 4},
            "l": {"default": "10 log ", "len_gain": 5},
            "L": {"default": "ln ", "len_gain": 5},
            "p": {"default": "P", "len_gain": 0},
            "P": {"default": "C", "len_gain": 0}
        }
        """;
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
            var rules = new Json.Parser();
            try {
                rules.load_from_data(replacement_rules_scientific.strip(), -1);
                var obj = rules.get_root().get_object();
                if (!obj.has_member(current_symbol)) {
                    len_gain = 0;
                    return current_symbol;
                }
                var rule = obj.get_object_member(current_symbol);
                // Generic double replacement: if the rule has a "double" key and the previous symbol matches the current one
                var to_be_replaced_with = rule.get_string_member("default");

                if (rule.has_member("double") && previous_symbol.strip () == to_be_replaced_with.strip ()) {
                    len_gain = (int) rule.get_int_member("len_gain");
                    double_replaced = true;
                    return rule.get_string_member("double");
                }
                // Handle radial mode for x
                if (current_symbol == "x" && radial_mode && rule.has_member("radial")) {
                    len_gain = (int) rule.get_int_member("len_gain");
                    return rule.get_string_member("radial");
                }
                len_gain = (int) rule.get_int_member("len_gain");
                return to_be_replaced_with;
            } catch (Error e) {
                len_gain = 0;
                return current_symbol;
            }
        }
    }
}
