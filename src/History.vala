namespace Pebbles {
    public class HistoryViewModel : Object {
        public int id { get; set; }
        public string context { get; set; }
        public string input { get; set; }
        public string output { get; set; }

        public HistoryViewModel (int id, string context, string input, string output) {
            this.id = id;
            this.context = context;
            this.input = input;
            this.output = output;
        }

        public void to_string () {
            print ("%u>\tContext: %s, Input: %s, Output: %s\n", id, context, input, output);
        }
    }
}
