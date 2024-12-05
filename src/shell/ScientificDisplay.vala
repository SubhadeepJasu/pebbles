namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/scientific_display.ui")]
    public class ScientificDisplay : Display {
        private bool _shift_on;
        public bool shift_on {
            get {
                return _shift_on;
            } set {
                _shift_on = value;
                shift_label.opacity = value ? 1 : 0.2;
            }
        }

        [GtkChild]
        private unowned Gtk.Label shift_label;
        [GtkChild]
        private unowned Gtk.Label main_label;
        [GtkChild]
        private unowned Gtk.Entry main_entry;

        private int animation_frame = 0;
        private string[] animation_frames = {"⠋ |       ",
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

        construct {
            visible = true;

            Idle.add (()=> {
                Timeout.add (60, ()=> {
                    if (animation_frame < animation_frames.length) {
                        main_label.label = animation_frames[animation_frame];
                        animation_frame++;
                        return true;
                    }

                    main_label.label = "0";
                    main_entry.grab_focus ();

                    return false;
                });

                return false;
            }, Priority.LOW);
        }
    }
}