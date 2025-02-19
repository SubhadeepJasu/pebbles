namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/statistics_display.ui")]
    public class StatisticsDisplay : Display {
        public string add_cell_warning_text { get; construct; }

        construct {
            add_cell_warning_text = "▭+  " + _("Enter data by adding new cell");
        }
    }
}
