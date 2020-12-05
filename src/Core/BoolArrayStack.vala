public class BoolArrayStack {
    public bool[,] stack;
    private int tp;
    private int n;
    private bool[] temp;
    public BoolArrayStack (int num) {
        n = num;
        stack = new bool[num, 64];
        tp = -1;
    }
    public bool push (bool[] elem) {
        if (tp < n) {
            tp++;
            for (int i = 0; i < 64; i++) {
                stack[tp, i] = elem[i];
            }
            return true;
        }
        else {
            return false;
        }
    }
    public bool[] pop () {
        temp = new bool[64];
        if (tp >= 0) {
            for (int i = 0; i < 64; i++) {
                temp[i] = stack [tp, i];
            }
            tp--;
            return temp;
        }
        bool[] temp_bool = new bool[64];
        return temp_bool;
    }
}