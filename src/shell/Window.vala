// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        private unowned Adw.ToastOverlay toast_overlay;
        
        [GtkChild]
        private unowned Adw.HeaderBar main_headerbar;

        [GtkChild]
        private unowned Gtk.Box navigation_pane;
        [GtkChild]
        private unowned Gtk.Box main_view;

        [GtkChild]
        private unowned ScientificView scientific_view;
        construct {
            navigation_pane.add_css_class (Granite.STYLE_CLASS_SIDEBAR);

            var menu_button = new Gtk.MenuButton() {
                icon_name = "preferences-system-symbolic",
                height_request = 28,
                width_request = 28
            };
            main_headerbar.pack_end (menu_button);

            var app_menu = new Menu ();
            menu_button.menu_model = app_menu;

            app_menu.append (_("Preferences"), "app.preferences");


            var history_button = new Gtk.Button.from_icon_name ("document-open-recent-symbolic") {
                height_request = 28,
                width_request = 28
            };
            main_headerbar.pack_end (history_button);
        }
    }
}