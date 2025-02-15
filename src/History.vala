namespace Pebbles {
    public class HistoryViewModel : Object {
        public string mode { get; set; }
        public string input { get; set; }
        public string output { get; set; }

        public HistoryViewModel (string mode, string input, string output) {
            this.mode = mode;
            this.input = input;
            this.output = output;
        }

        public void to_string () {
            print ("Mode: %s, Input: %s, Output: %s\n", mode, input, output);
        }
    }
}
