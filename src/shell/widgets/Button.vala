namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/button.ui")]
    public class Button : Gtk.Button {
        public const string STYLE_BTN_PRESSED = "pressed";

        [GtkChild]
        private unowned Gtk.Label btn_label;
        public string label_text {
            get {
                return btn_label.get_text ();
            }

            set construct {
                btn_label.set_text (value);
                btn_label.use_markup = true;
            }
        }

        public string icon {
            get {
                return icon_name;
            }

            set {
                icon_name = value;
                btn_label.visible = value.length == 0;

                if (icon_name.length > 0) {
                    remove_css_class ("image-button");
                }
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

        private uint[] keyvals;
        private string? _key;
        public string? key {
            get {
                return _key;
            }
            set {
                _key = value;
                var keys = value.split (",", 128);
                if (keyvals == null) {
                    keyvals = new uint[keys.length];
                }

                for (uint8 i = 0; i < keys.length; i++) {
                    var __key = keys[i].chug ();
                    if (_key == "<Shift>Tab") { // Modifier key enabled for Tab
                        keyvals[i] = 65056;
                    } else if (__key.length == 1) {
                        keyvals[i] = Gdk.unicode_to_keyval (__key.get_char (0));
                    } else if (__key.length > 1) {
                        keyvals[i] = Gdk.keyval_from_name (__key);
                    }
                }
            }
        }

        construct {
            btn_label.set_use_markup (true);

            realize.connect_after (() => {
                var window = (Pebbles.MainWindow) get_ancestor (typeof (Pebbles.MainWindow));
                window.on_key_down.connect ((mode, keyval) => {
                    if (visible && is_key (keyval)) {
                        show_as_pressed ();
                    }
                });

                window.on_key_up.connect ((mode, keyval) => {
                    if (visible && is_key (keyval)) {
                        show_as_pressed (false);
                    }
                });
            });
        }

        public void show_as_pressed (bool? pressed = true) {
            if (pressed) {
                add_css_class (STYLE_BTN_PRESSED);
            } else {
                remove_css_class (STYLE_BTN_PRESSED);
            }
        }

        private bool is_key (uint keyval) {
            foreach (uint _keyval in this.keyvals) {
                if (_keyval == keyval) {
                    return true;
                }
            }

            return false;
        }
    }
}
