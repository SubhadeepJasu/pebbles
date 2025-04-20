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
    }
}
