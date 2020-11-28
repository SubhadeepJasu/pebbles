public class CharStack {
    public char[] stack;
    private int top;
    private int n;
    private char temp;
    public CharStack (int num) {
        n = num;
        stack = new char[num];
        top = -1;
    }
    public bool push (char elem) {
        if (top < n) {
            ++top;
            stack[top] = elem;
            return true;
        }
        else {
            return false;
        }
    }
    public char pop () {
        if (top >= 0) {
            temp = stack[top];
            top--;
            return temp;
        }
        return temp;
    }
    public char peek () {
        if (top >= 0) {
            return stack[top];
        }
        return '0';
    }
    public bool empty() {
        if (top < 0) {
            return true;
        }
        else {
            return false;
        }
    }
}