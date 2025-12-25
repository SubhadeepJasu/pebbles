namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/conv_currency_view.ui")]
    public class ConvCurrencyView : ConverterView {
        public signal void start_api_call ();
        public signal void end_api_call (string message);

        construct {
            conversion_factors = new double[12];

            string[] units = {
                (_("US Dollar") + ": $"),
                (_("Euro") + ": €"),
                (_("British Pounds") + ": £"),
                (_("Australian Dollar") + ": $"),
                (_("Brazilian Real") + ": R$"),
                (_("Canadian Dollar") + ": $"),
                (_("Chinese Yuan") + ": ¥"),
                (_("Indian Rupee") + ": ₹"),
                (_("Japanese Yen") + ": ¥"),
                (_("Russian Ruble") + ": руб"),
                (_("South African Rand") + ": R"),
                (_("Argentine Peso") + ": $"),
            };

            unit_options = new Gtk.StringList (units);
        }

        public async void update_forex_data (bool force = false) throws ApiError {
            var settings = Pebbles.Settings.get_default ();

            var last_updated = new DateTime.from_unix_utc (settings.forex_api_last_updated);
            var now = new DateTime.now_utc ();

            if (now.difference (last_updated) < 3600000000 && settings.forex_rates_cache.length > 0 && !force) {
                load_from_cache ();
                end_api_call ("");
                additional_label.label = last_updated.to_local ().format (_("Last updated: %B %d, %Y %I:%M %p"));
                return;
            }

            start_api_call ();
            print ("Calling API\n");
            string api_key = settings.forex_api_key;

            if (api_key == "") {
                end_api_call ("Please provide an API key in preferences dialog.");
                throw new ApiError.NO_API_KEY (_("Please provide an API key in preferences dialog."));
            }

            const string[] CURRS = {
                "EUR",
                "GBP",
                "AUD",
                "BRL",
                "CAD",
                "CNY",
                "INR",
                "JPY",
                "RUB",
                "ZAR",
                "ARS"
            };

            string query_string =
            "?app_id=%s&base=USD&symbols=%s".printf (api_key, string.joinv (",", CURRS));

            string request = "https://openexchangerates.org/api/latest.json" + query_string;

            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", request);

            try {
                var response = yield session.send_async (message, 0, null);

                var parser = new Json.Parser ();
                parser.load_from_stream (response);
                var root_object = parser.get_root ().get_object ();

                var data = root_object.get_object_member ("rates");

                if (data != null) {
                    conversion_factors[0] = 1.0;
                    conversion_factors[1] = data.get_double_member ("EUR");
                    conversion_factors[2] = data.get_double_member ("GBP");
                    conversion_factors[3] = data.get_double_member ("AUD");
                    conversion_factors[4] = data.get_double_member ("BRL");
                    conversion_factors[5] = data.get_double_member ("CAD");
                    conversion_factors[6] = data.get_double_member ("CNY");
                    conversion_factors[7] = data.get_double_member ("INR");
                    conversion_factors[8] = data.get_double_member ("JPY");
                    conversion_factors[9] = data.get_double_member ("RUB");
                    conversion_factors[10] = data.get_double_member ("ZAR");
                    conversion_factors[11] = data.get_double_member ("ARS");

                    end_api_call ("");
                    settings.forex_api_last_updated = (int) root_object.get_int_member ("timestamp");
                    last_updated = new DateTime.from_unix_utc (settings.forex_api_last_updated);
                    additional_label.label = last_updated.to_local ().format (_("Last updated: %B %d, %Y %I:%M %p"));
                    from_entry.text = "1";
                    from_entry.grab_focus_without_selecting ();
                    from_entry.set_position (1);

                    string[] cache = new string[conversion_factors.length];

                    for (int i = 0; i < conversion_factors.length; i++) {
                        cache[i] = conversion_factors[i].to_string ();
                    }

                    settings.forex_rates_cache = cache;
                } else {
                    var err_message = root_object.get_string_member ("message");
                    if (err_message == "invalid_app_id") {
                        end_api_call ("Invalid app key for Forex API");
                    }

                    load_from_cache ();
                    additional_label.label = last_updated.to_local ().format (_("Last updated: %B %d, %Y %I:%M %p"));
                }
            } catch (Error r) {
                warning (r.message);
                end_api_call ("Failed to fetch Forex data!");
                load_from_cache ();
                additional_label.label = last_updated.to_local ().format (_("Last updated: %B %d, %Y %I:%M %p"));
                throw new ApiError.CONNECTION_FAILED (r.message);
            }
        }

        private void load_from_cache () {
            print ("Loaded currency data from cache.\n");
            var cache = Pebbles.Settings.get_default ().forex_rates_cache;
            for (int i = 0; i < cache.length; i++) {
                conversion_factors[i] = double.parse (cache[i]);
            }

            from_entry.text = "1";
            from_entry.grab_focus_without_selecting ();
            from_entry.set_position (1);
        }
    }

    public errordomain ApiError {
        NO_API_KEY,
        CONNECTION_FAILED
    }
}
