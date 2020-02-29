/*-
 * Copyright (c) 2017-2020 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright (c) 2017-2020 Saunak Biswas <saunakbis97@gmail.com>
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
 */

// Using Alpha Vantage <https://www.alphavantage.co>
// API KEY: RXOIDV8ZZ8W29VK9

// For FCSAPI <https://fcsapi.com>
// API KEY: KV9lazf1j19qahz958FCKc051xvDEc5ZcFw1v7uTbkHa9CBl6D

using Soup;
using Json;

namespace Pebbles {
    public class CurrencyConverter {
        public string[] currency = {
            "USD",
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
        };
        public double[] muliplier_info; 

        public signal void currency_updated (double[] currency_multipliers);
        public signal void update_failed ();

        public CurrencyConverter () {
            muliplier_info = new double [11];
        }

        public bool request_update () {
            if (!Thread.supported ()) {
                warning (_("Thread support missing. Please wait for web API access...\n"));
                update_currency_thread ();
                return true;
            }
            else {
                try {
                    new Thread<int>.try ("thread_a", update_currency_thread);

                } catch (Error e) {
                    warning ("%s\n", e.message);
                    return false;
                }
            }
            return true;
        }
        int update_currency_thread () {
            int cnt = 0;
            for (int i = 0; i < 11; i++) {
                for (int j = 0; j < 2; j++) {
                    if (request_multiplier ("USD", currency [i], i)) {
                        cnt++;
                        break;
                    }
                }
            }
            if (cnt < 11) {
                warning (_("Failed to connect to currency exchange service"));
                update_failed ();
            }
            else {
                currency_updated (muliplier_info);
            }
            return 0;
        }
        public bool request_multiplier (string coin_iso_a, string coin_iso_b, int index) {
            var uri = """https://free.currencyconverterapi.com/api/v6/convert?q=%s_%s&compact=y&apiKey=03eb97e97cbf3fa3e228""".printf(coin_iso_a, coin_iso_b);
            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", uri);
            double avg = 0.0;

            if(session.send_message (message) != 200) {
                return false;
            }

            try {
                var parser = new Json.Parser ();
                parser.load_from_data ((string) message.response_body.flatten ().data, -1);
                var root_object = parser.get_root ().get_object();
                var response_object = root_object.get_object_member ("%s_%s".printf (coin_iso_a, coin_iso_b));
                avg = response_object.get_double_member("val");
                muliplier_info [index] = avg;
                //stdout.printf ("DEBUG_CURRENCY => %s -> %s: %lf\n", coin_iso_a, coin_iso_b, muliplier_info [index]);
            } catch (Error e) {
                warning (_("Failed to connect to service: %s"), e.message);
                return false;
            }
            return true;
        }
    }
}
