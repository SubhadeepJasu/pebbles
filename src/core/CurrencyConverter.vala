/*-
 * Copyright (c) 2018-2019 Subhadeep Jasu <subhajasu@gmail.com>
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

using Soup;
using Json;

namespace Pebbles {
    public class CurrencyConverter {
        public enum Currency {
            USD = 0,
            EUR = 1,
            GBP = 2,
            AUD = 3,
            BRL = 4,
            CAD = 5,
            CNY = 6,
            INR = 7,
            JPY = 8,
            RUB = 9,
            ZAR = 10
        }
        public static bool request_update (string coin_iso_a, string coin_iso_b) {
            var uri = """https://free.currencyconverterapi.com/api/v6/convert?q=%s_%s&compact=y""".printf(coin_iso_a, coin_iso_b);
            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", uri);
            double avg = 0.0;

            session.send_message (message);

            try {
                var parser = new Json.Parser ();
                parser.load_from_data ((string) message.response_body.flatten ().data, -1);
                var root_object = parser.get_root ().get_object();
                var response_object = root_object.get_object_member ("%s_%s".printf (coin_iso_a, coin_iso_b));
                avg = response_object.get_double_member("val");
            } catch (Error e) {
                warning ("Failed to connect to service: %s", e.message);
                return false;
            }
            return true;
        }
    }
}
