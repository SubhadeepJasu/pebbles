namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/display.ui")]
    public class Display : Gtk.Grid {
        protected int animation_frame = 0;
        protected string[] animation_frames = {"⠋ |       ",
                                             "⠙ P|      ",
                                             "⠹ PE|     ",
                                             "⠸ PEB|    ",
                                             "⠼ PEBB|   ",
                                             "⠴ PEBBL|  ",
                                             "⠦ PEBBLE| ",
                                             "⠧ PEBBLES|",
                                             "⠇ PEBBLES|",
                                             "⠏ PEBBLES|",
                                             "⠋ PEBBLES ",
                                             "⠙ PEBBLES ",
                                             "⠹ PEBBLES ",
                                             "⠸ PEBBLES|",
                                             "⠼ PEBBLES|",
                                             "⠴ PEBBLES|",
                                             "⠦ BBLES ",
                                             "⠧ LES ",
                                             "⠇ S ",
                                             "⠏"};

        public signal void on_input (string text);

        construct {
            visible = true;
        }
    }
}