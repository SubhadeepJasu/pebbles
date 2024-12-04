namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/styled_button.ui")]
    public class StyledButton : Gtk.Button {
        [GtkChild]
        private unowned Gtk.Label btn_label;
        public string label_text {
            get {
                return btn_label.get_text ();
            }

            set construct {
                btn_label.set_text (value);
            }
        }

        private string _tooltip_desc;
        public string tooltip_desc {
            get {
                return _tooltip_desc;
            }
            set construct {
                _tooltip_desc = value;
                if (accel_markup != null) {
                    tooltip_markup = Granite.markup_accel_tooltip (accel_markup.split (","), tooltip_desc);
                } else {
                    tooltip_text = tooltip_desc;
                }
            }
        }

        private string? _accel_markup;
        public string? accel_markup {
            get {
                return _accel_markup;
            }
            set construct {
                _accel_markup = value;
                if (value != null) {
                    tooltip_markup = Granite.markup_accel_tooltip (value.split (","), tooltip_desc);
                } else {
                    tooltip_text = tooltip_desc;
                }
            }
        }

        construct {
            btn_label.set_use_markup (true);
        }
    }
}