namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/display.ui")]
    public abstract class Display : Gtk.Grid {
        public string context { get; set; }
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
