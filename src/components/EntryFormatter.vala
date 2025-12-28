// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>

namespace Pebbles {
    /**
     * Replacement modes for mathematical symbols in the input.
     */
    public enum ReplacementMode {
        /** No replacement */
        NONE,
        /** Scientific mode for mathematical expressions */
        SCIENTIFIC,
        /** Programmer mode for logical expressions */
        PROGRAMMER
    }

    /**
     * The EntryFormatter class is responsible for formatting user input in a Gtk.Entry widget.
     * It applies modular replacement rules to convert simple symbol inputs into their corresponding
     * mathematical or logical representations based on a specified ReplacementMode
     * (`SCIENTIFIC` or `PROGRAMMER`).
     */
    public class EntryFormatter {
        // Replacement rules for scientific mode
        private const string REPLACEMENT_RULES_SCIENTIFIC = """
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

        // Replacement rules for programmer mode
        private const string REPLACEMENT_RULES_PROGRAMMER = """
        {
            "@": {"default": "ans", "len_gain": 2},
            "#": {"default": "sans", "len_gain": 3},
            "o": {"default": " or ", "len_gain": 3},
            "O": {"default": " nor ", "len_gain": 4},
            "n": {"default": " and ", "len_gain": 4},
            "N": {"default": " nand ", "len_gain": 5},
            "x": {"default": " xor ", "len_gain": 4},
            "X": {"default": " xnor ", "len_gain": 5},
            "t": {"default": " not ", "len_gain": 4},
            "T": {"default": " mod ", "len_gain": 4},
            "m": {"default": " mod ", "len_gain": 4},
            "M": {"default": " mod ", "len_gain": 4},
            "+": {"default": " + ", "len_gain": 2},
            "-": {"default": " − ", "len_gain": 2},
            "−": {"default": " − ", "len_gain": 2},
            "×": {"default": " × ", "len_gain": 2},
            "*": {"default": " × ", "len_gain": 2},
            "÷": {"default": " ÷ ", "len_gain": 2},
            "/": {"default": " ÷ ", "len_gain": 2},
            ",": {"default": " lsh ", "len_gain": 4},
            ".": {"default": " rsh ", "len_gain": 4},
            "<": {"default": " rsh ", "len_gain": 4},
            ">": {"default": " rsh ", "len_gain": 4},
            "l": {"default": " lsh ", "len_gain": 4},
            "L": {"default": " rsh ", "len_gain": 4},
            "(": {"default": "(", "len_gain": 0},
            ")": {"default": ")", "len_gain": 0}
        }
        """;

        public unowned Gtk.Entry main_entry;
        public bool polar_mode;
        private bool auto_entry;
        public bool disabled { get; set; }
        public ReplacementMode replacement_mode { get; set; }

        public signal bool on_input (string full_expression, int input_length, string input_char);

        /**
         * Constructor for EntryFormatter.
         * @param entry The Gtk.Entry widget to format
         * @param mode The ReplacementMode to use (default is SCIENTIFIC)
         */
        public EntryFormatter (Gtk.Entry entry, ReplacementMode mode = ReplacementMode.SCIENTIFIC) {
            this.main_entry = entry;
            this.replacement_mode = mode;

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

                    if (mode == ReplacementMode.NONE) {
                        return Source.REMOVE;
                    }

                    Idle.add (() => {
                        if (main_entry.text_length >= 1 && main_entry.text != "0")
                            replace_inserted_character (
                                main_entry.text,
                                main_entry.text_length,
                                main_entry.get_position (),
                                ch,
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

                    on_input (main_entry.text, (int) main_entry.text_length, "");

                    return Source.REMOVE;
                });
            });
        }

        public void replace_inserted_character (
            string text,
            uint text_length,
            int caret_pos,
            string current_symbol,
            bool radial_mode = false
        ) {
            var symbols = split_utf8 (text, text_length);
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
            var main_entry_text = string.joinv ("", symbols);

            if (!on_input (main_entry_text, (int) main_entry.text_length, current_symbol)) {
                main_entry.text = main_entry_text;

                if (double_replaced) {
                    main_entry.set_position (caret_pos - 1);
                } else {
                    main_entry.set_position (caret_pos + len_gain);
                }
            } else {
                symbols[caret_pos] = "";
                main_entry.text = string.joinv ("", symbols);
                main_entry.set_position (caret_pos - 1);
            }
            auto_entry = false;
        }

        private string[] split_utf8 (string text, uint text_length) {
            var result = new string[text_length + 1];
            var j = 0;

            var sb = new StringBuilder ();
            for (int i = 0; i <= text.length; i++) {
                if ((text[i] & 0xC0) != 0x80) { // Prevent commiting if it's a continuation bit
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
            out int len_gain) {
            double_replaced = false;
            var rules = new Json.Parser ();
            try {
                // Select rules based on replacement_mode
                string rule_json = (replacement_mode == ReplacementMode.PROGRAMMER)
                    ? REPLACEMENT_RULES_PROGRAMMER
                    : REPLACEMENT_RULES_SCIENTIFIC;

                rules.load_from_data (rule_json.strip (), -1);
                var obj = rules.get_root ().get_object ();
                if (!obj.has_member (current_symbol)) {
                    len_gain = 0;
                    return current_symbol;
                }
                var rule = obj.get_object_member (current_symbol);

                var to_be_replaced_with = rule.get_string_member ("default");
                if (rule.has_member ("double") && previous_symbol.strip () == to_be_replaced_with.strip ()) {
                    len_gain = (int) rule.get_int_member ("len_gain");
                    double_replaced = true;
                    return rule.get_string_member ("double");
                }
                if (current_symbol == "x" && radial_mode && rule.has_member ("radial")) {
                    len_gain = (int) rule.get_int_member ("len_gain");
                    return rule.get_string_member ("radial");
                }
                len_gain = (int) rule.get_int_member ("len_gain");
                return to_be_replaced_with;
            } catch (Error e) {
                len_gain = 0;
                return current_symbol;
            }
        }

        public bool is_rule_present (string input_symbol) {
            var rules = new Json.Parser ();
            try {
                string rule_json = (replacement_mode == ReplacementMode.PROGRAMMER)
                    ? REPLACEMENT_RULES_PROGRAMMER
                    : REPLACEMENT_RULES_SCIENTIFIC;
                rules.load_from_data (rule_json.strip (), -1);
                var obj = rules.get_root ().get_object ();
                return obj.has_member (input_symbol);
            } catch (Error e) {
                return false;
            }
        }
    }
}
