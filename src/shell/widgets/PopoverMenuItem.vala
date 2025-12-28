// SPDX-FileCopyrightText: 2024 elementary, Inc. <https://elementary.io>, 2024 Subhadeep Jasu <subhadeep107@proton.me>
// SPDX-License-Identifier: GPL-3.0-or-later

// Code adapted from elementary OS's Tasks
namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/popover_menu_item.ui")]
    public class PopoverMenuItem : Gtk.Button {
        public string text { get; construct; }
        public string accel { get; construct; }

        construct {
            add_css_class (Granite.STYLE_CLASS_MENUITEM);

            child = new Granite.AccelLabel (text, accel) {
                action_name = this.action_name
            };

            clicked.connect (() => {
                var popover = (Gtk.Popover) get_ancestor (typeof (Gtk.Popover));
                if (popover != null) {
                    popover.popdown ();
                }
            });
        }
    }
}
