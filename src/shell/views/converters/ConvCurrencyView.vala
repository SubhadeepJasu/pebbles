// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/conv_currency_view.ui")]
    public class ConvCurrencyView : ConverterView {
        // Keyless source, used when no openexchangerates key is set.
        // Shows rates in the UI, so the label links back to the provider.
        private const string KEYLESS_LATEST_URL =
            "https://allratestoday.com/api/open/latest/USD";
        private const string KEYLESS_CENTRAL_BANK_URL =
            "https://allratestoday.com/api/open/central-bank/%s";
        private const string KEYLESS_ATTRIBUTION_URL =
            "https://allratestoday.com";

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
                show_last_updated (last_updated);
                return;
            }

            start_api_call ();
            print ("Calling API\n");
            string api_key = settings.forex_api_key;

            if (api_key == "") {
                yield update_forex_data_keyless ();
                return;
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

                    settings.forex_api_last_updated = (int) root_object.get_int_member ("timestamp");
                    apply_new_rates ();
                } else {
                    var err_message = root_object.get_string_member ("message");
                    if (err_message == "invalid_app_id") {
                        end_api_call ("Invalid app key for Forex API");
                    }

                    load_from_cache ();
                    show_last_updated (last_updated);
                }
            } catch (Error r) {
                warning (r.message);
                end_api_call ("Failed to fetch Forex data!");
                load_from_cache ();
                show_last_updated (last_updated);
                throw new ApiError.CONNECTION_FAILED (r.message);
            }
        }

        // No API key: ECB reference rates from allratestoday.com (keyless).
        // ECB has no RUB or ARS, so those come from the Bank of Russia and
        // the Central Bank of Argentina tables on the same service.
        private async void update_forex_data_keyless () throws ApiError {
            var settings = Pebbles.Settings.get_default ();
            var session = new Soup.Session ();

            try {
                var root_object = yield fetch_json (session, KEYLESS_LATEST_URL);
                if (!root_object.has_member ("rates")) {
                    throw new ApiError.CONNECTION_FAILED ("No rates in response");
                }

                var data = root_object.get_object_member ("rates");

                conversion_factors[0] = 1.0;
                conversion_factors[1] = data.get_double_member ("EUR");
                conversion_factors[2] = data.get_double_member ("GBP");
                conversion_factors[3] = data.get_double_member ("AUD");
                conversion_factors[4] = data.get_double_member ("BRL");
                conversion_factors[5] = data.get_double_member ("CAD");
                conversion_factors[6] = data.get_double_member ("CNY");
                conversion_factors[7] = data.get_double_member ("INR");
                conversion_factors[8] = data.get_double_member ("JPY");
                conversion_factors[10] = data.get_double_member ("ZAR");
            } catch (Error e) {
                warning (e.message);
                end_api_call ("Failed to fetch Forex data!");
                load_from_cache ();
                show_last_updated (
                    new DateTime.from_unix_utc (settings.forex_api_last_updated)
                );
                throw new ApiError.CONNECTION_FAILED (e.message);
            }

            conversion_factors[9] = yield fetch_central_bank_rate (
                session, "cbr", "RUB", 9
            );
            conversion_factors[11] = yield fetch_central_bank_rate (
                session, "bcra", "ARS", 11
            );

            var now = new DateTime.now_utc ();
            settings.forex_api_last_updated = (uint) now.to_unix ();
            apply_new_rates ();
        }

        // USD rate for one currency from a central bank table.
        // Falls back to the cached value if the call fails.
        private async double fetch_central_bank_rate (
            Soup.Session session,
            string bank,
            string quote,
            int index
        ) {
            try {
                var root_object = yield fetch_json (
                    session, KEYLESS_CENTRAL_BANK_URL.printf (bank)
                );

                if (root_object.has_member ("rates")) {
                    var rates = root_object.get_array_member ("rates");
                    foreach (unowned Json.Node node in rates.get_elements ()) {
                        var row = node.get_object ();
                        if (row.get_string_member ("base") == "USD" &&
                            row.get_string_member ("quote") == quote) {
                            return row.get_double_member ("value");
                        }
                    }
                }

                warning ("USD/%s missing from %s table", quote, bank);
            } catch (Error e) {
                warning (e.message);
            }

            var cache = Pebbles.Settings.get_default ().forex_rates_cache;
            return index < cache.length ? double.parse (cache[index]) : 0.0;
        }

        private async Json.Object fetch_json (Soup.Session session, string url) throws Error {
            var message = new Soup.Message ("GET", url);
            var response = yield session.send_async (message, 0, null);

            if (message.status_code != 200) {
                throw new ApiError.CONNECTION_FAILED (
                    "HTTP %u from %s".printf (message.status_code, url)
                );
            }

            var parser = new Json.Parser ();
            parser.load_from_stream (response);
            var root = parser.get_root ();

            if (root == null || root.get_node_type () != Json.NodeType.OBJECT) {
                throw new ApiError.CONNECTION_FAILED ("Unexpected response from %s".printf (url));
            }

            return root.get_object ();
        }

        private void apply_new_rates () {
            var settings = Pebbles.Settings.get_default ();

            end_api_call ("");
            show_last_updated (new DateTime.from_unix_utc (settings.forex_api_last_updated));
            from_entry.text = "1";
            from_entry.grab_focus_without_selecting ();
            from_entry.set_position (1);

            string[] cache = new string[conversion_factors.length];

            for (int i = 0; i < conversion_factors.length; i++) {
                cache[i] = conversion_factors[i].to_string ();
            }

            settings.forex_rates_cache = cache;
        }

        private void show_last_updated (DateTime last_updated) {
            string text = last_updated.to_local ().format (_("Last updated: %B %d, %Y %I:%M %p"));

            if (Pebbles.Settings.get_default ().forex_api_key == "") {
                additional_label.use_markup = true;
                additional_label.label = "%s · %s <a href=\"%s\">allratestoday.com</a>".printf (
                    Markup.escape_text (text),
                    Markup.escape_text (_("Rates:")),
                    KEYLESS_ATTRIBUTION_URL
                );
            } else {
                additional_label.use_markup = false;
                additional_label.label = text;
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
