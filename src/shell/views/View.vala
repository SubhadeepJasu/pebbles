// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>

namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/view.ui")]
    public abstract class View : Gtk.Grid {
        public string context { get; protected set; }
        public string radix_symbol {
            get {
                return get_local_radix_symbol ();
            }
        }

        public void fade_in () {
            add_css_class ("animate");
            Timeout.add_once (600, () => {
                remove_css_class ("animate");
            });
        }

        /** Focus on the main widget of the view. */
        public abstract void focus_main ();

        /** Copy result to clipboard. */
        public abstract void copy ();
    }
}
