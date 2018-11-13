/*-
 * Copyright (c) 2017-2018 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 *              Saunak Biswas  <saunakbis97@gmail.com>
 */

namespace Pebbles {
    public class MainWindow : Gtk.Window {
        // CONTROLS
        Gtk.HeaderBar headerbar;
        Granite.ModeSwitch dark_mode_switch;
        Pebbles.Settings settings;
        Gtk.Button angle_unit_button;
        Gtk.Grid shift_grid;
        Gtk.Label shift_label;
        public Gtk.Switch shift_switch;
        Gtk.MenuButton app_menu;
        Gtk.Button history_button;

        // VIEWS
        Pebbles.ScientificView scientific_view;
        Pebbles.ProgrammerView programmer_view;
        Pebbles.CalculusView   calculus_view;
        Pebbles.DateView       date_view;

        Pebbles.ConvLengthView conv_length_view;
        Pebbles.ConvAreaView   conv_area_view;
        Pebbles.ConvVolumeView conv_volume_view;
        //Pebbles.ConvPressView  conv_press_view;
        //Pebbles.ConvWeightView conv_weight_view;
        //Pebbles.ConvEnergyView conv_energy_view;
        //Pebbles.ConvTempView   conv_temp_view;
        //Pebbles.ConvPowerView  conv_power_view;
        //Pebbles.ConvSpeedView  conv_speed_view;
        //Pebbles.ConvAngleView  conv_angle_view;
        //Pebbles.ConvDataView   conv_data_view;
        // Active View Index
        private int view_index = 0;
        
        // NOTIFICATION
        Notification desktop_notification;
        
        // History
        List<string> history_stack;

        public MainWindow () {
            load_settings ();
            make_ui ();
            handle_focus ();
        }

        construct {
            settings = Pebbles.Settings.get_default ();
            settings.notify["use-dark-theme"].connect (() => {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.use_dark_theme;
            });
            this.delete_event.connect (() => {
                save_settings ();
            });
            history_stack = new List<string> ();
            history_stack.append ("3.14159265");
        }
        
        public void make_ui () {
            // Create dark mode switcher
            dark_mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic");
            dark_mode_switch.primary_icon_tooltip_text = ("Light background");
            dark_mode_switch.secondary_icon_tooltip_text = ("Dark background");
            dark_mode_switch.valign = Gtk.Align.CENTER;
            dark_mode_switch.active = settings.use_dark_theme;
            dark_mode_switch.notify["active"].connect (() => {
                settings.use_dark_theme = dark_mode_switch.active;
            });
            
            // Create angle unit button
            angle_unit_button = new Gtk.Button.with_label ("DEG");
            angle_unit_button.margin = 12;
            angle_unit_button.clicked.connect (() => {
                settings.switch_angle_unit ();
                angle_unit_button_label_update ();
            });
            
            // Create shift switcher
            shift_grid = new Gtk.Grid ();
            shift_label = new Gtk.Label ("\tShift ");
            shift_switch = new Gtk.Switch ();
            shift_switch.get_style_context ().add_class ("Pebbles_Header_Switch");
            shift_switch.notify["active"].connect (() => {
                scientific_view.hold_shift (shift_switch.active);
            });
            shift_grid.attach (shift_label, 0, 0, 1, 1);
            shift_grid.attach (shift_switch, 1, 0, 1, 1);
            shift_grid.valign = Gtk.Align.CENTER;
            shift_grid.column_spacing = 6;
            
            // Create App Menu
            app_menu = new Gtk.MenuButton ();
            app_menu.valign = Gtk.Align.CENTER;
            app_menu.set_image (new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
            
            var settings_menu = new Gtk.Menu ();
            var menu_item_constants = new Gtk.MenuItem.with_label ("Configure Constant Button");

            settings_menu.append (menu_item_constants);
            settings_menu.show_all();
            
            app_menu.popup = settings_menu;
            
            // Create History Button
            history_button = new Gtk.Button ();
            history_button.valign = Gtk.Align.CENTER;
            history_button.set_image (new Gtk.Image.from_icon_name ("document-open-recent-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
            
            // Create headerbar
            headerbar = new Gtk.HeaderBar ();
            headerbar.title = ("Pebbles");
            headerbar.get_style_context ().add_class ("default-decoration");
            headerbar.show_close_button = true;
            headerbar.pack_start (angle_unit_button);
            headerbar.pack_start (shift_grid);
            headerbar.pack_end (history_button);
            headerbar.pack_end (app_menu);
            headerbar.pack_end (dark_mode_switch);
            this.set_titlebar (headerbar);
            
            // Create Item Pane
            var scientific_item  = new Granite.Widgets.SourceList.Item ("Scientific");
            var programmer_item  = new Granite.Widgets.SourceList.Item ("Programmer");
            var calculus_item    = new Granite.Widgets.SourceList.Item ("Calculus");
            var date_item        = new Granite.Widgets.SourceList.Item ("Date");
            var conv_length_item = new Granite.Widgets.SourceList.Item ("Length");
            var conv_area_item   = new Granite.Widgets.SourceList.Item ("Area");
            var conv_volume_item = new Granite.Widgets.SourceList.Item ("Volume");
            
            // Calculators
            var calc_category = new Granite.Widgets.SourceList.ExpandableItem ("Calculator");
            calc_category.expand_all ();
            calc_category.add (scientific_item);
            calc_category.add (programmer_item);
            calc_category.add (calculus_item);
            calc_category.add (date_item);
            // Converters
            var conv_category = new Granite.Widgets.SourceList.ExpandableItem ("Converter");
            conv_category.expand_all ();
            conv_category.add (conv_length_item);
            conv_category.add (conv_area_item);
            conv_category.add (conv_volume_item);

            var item_list = new Granite.Widgets.SourceList ();
            item_list.root.add (calc_category);
            item_list.root.add (conv_category);
            
            // Create Views
            scientific_view  = new Pebbles.ScientificView (this);
            programmer_view  = new Pebbles.ProgrammerView ();
            calculus_view    = new Pebbles.CalculusView ();
            date_view        = new Pebbles.DateView ();
            conv_length_view = new Pebbles.ConvLengthView ();
            conv_area_view   = new Pebbles.ConvAreaView ();
            conv_volume_view = new Pebbles.ConvVolumeView ();
            
            // Create Views Pane
            var common_view = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            common_view.valign = Gtk.Align.CENTER;
            common_view.halign = Gtk.Align.CENTER;
            common_view.add (scientific_view);

            //Create Panes
            var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            paned.position = 170;
            paned.position_set = true;
            paned.pack1 (item_list, false, false);
            paned.pack2 (common_view, false, false);

            // Create View Events
            item_list.item_selected.connect ((item) => {
                if (item == scientific_item) {
                    common_view.foreach ((element) => common_view.remove (element));
                    common_view.add (scientific_view);
                    view_index = 0;
                }
                else if (item == programmer_item) {
                    common_view.foreach ((element) => common_view.remove (element));
                    common_view.add (programmer_view);
                    view_index = 1;
                }
                else if (item == calculus_item) {
                    common_view.foreach ((element) => common_view.remove (element));
                    common_view.add (calculus_view);
                    view_index = 2;
                }
                else if (item == conv_length_item) {
                    common_view.foreach ((element) => common_view.remove (element));
                    common_view.add (conv_length_view);
                    view_index = 4;
                }
                this.show_all ();
            });
            angle_unit_button_label_update ();
            //scientific_item.activated ();

            // Set up window attributes
            this.set_default_size (900, 600);
            this.set_size_request (900, 600);

            // Show all the stuff
            this.add (paned);
            this.set_resizable (false);
            this.show_all ();
        }

        public void answer_notify () {
            if (desktop_notification == null) {
                desktop_notification = new Notification ("");
            }
            if (history_stack.length () > 0) {
                unowned List<string>? last_answer = history_stack.last ();
                desktop_notification.set_title ("Copied to Clipboard");
                desktop_notification.set_body (last_answer.data);
                this.application.send_notification (PebblesApp.instance.application_id, desktop_notification);

                stdout.printf ("[STATUS]  Pebbles: Notification sent\n");
                
                // Manage clipboard
                Gdk.Display display = this.get_display ();
                Gtk.Clipboard clipboard = Gtk.Clipboard.get_for_display (display, Gdk.SELECTION_CLIPBOARD);
                clipboard.set_text (last_answer.data, -1);
            }
            else {
                desktop_notification.set_title ("History Empty!");
                desktop_notification.set_body ("Nothing has been calculated yet");
                this.application.send_notification (PebblesApp.instance.application_id, desktop_notification);

                stdout.printf ("[WARNING] Pebbles: History is empty\n");
            }
        }
        private void angle_unit_button_label_update () {
            if (settings.global_angle_unit == Pebbles.GlobalAngleUnit.DEG) {
                angle_unit_button.label = "DEG";
                scientific_view.set_angle_mode_display (0);
            }
            else if (settings.global_angle_unit == Pebbles.GlobalAngleUnit.RAD) {
                angle_unit_button.label = "RAD";
                scientific_view.set_angle_mode_display (1);
            }
            else if (settings.global_angle_unit == Pebbles.GlobalAngleUnit.GRAD) {
                angle_unit_button.label = "GRA";
                scientific_view.set_angle_mode_display (2);
            }
        }
        private void load_settings () {
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.use_dark_theme;
            if (settings.window_x < 0 || settings.window_y < 0 ) {
                this.window_position = Gtk.WindowPosition.CENTER;
            } else {
                this.move (settings.window_x, settings.window_y);
            }
        }

        private void save_settings () {
            int x, y;
            this.get_position (out x, out y);
            settings.window_x = x;
            settings.window_y = y;
        }

        private void handle_focus () {
            key_press_event.connect ((event) => {
                switch (view_index) {
                    case 0: 
                        scientific_view.display_unit.input_entry.grab_focus_without_selecting ();
                        if (scientific_view.display_unit.input_entry.get_text () == "0" && scientific_view.display_unit.input_entry.cursor_position == 0)
                            scientific_view.display_unit.input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                        break;
                    case 4:
                        conv_length_view.key_press_event (event);
                        break;
                }
                return false;
            });
        }

    }
}
