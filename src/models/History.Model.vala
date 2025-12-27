// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>

namespace Pebbles {
    public class HistoryModel : Object {
        public int id { get; set; }
        public string context { get; set; }
        public string input { get; set; }
        public string result { get; set; }
        public HistoryModelMetadata? metadata { get; set; default = null; }

        public static HistoryModel new_for_view (int id, string context, string input, string result) {
            var object = new HistoryModel ();
            object.id = id;
            object.context = context;
            object.input = input;
            object.result = result;
            return object;
        }

        public static HistoryModel new_from_db_response (
            int id,
            string context,
            string input,
            string result,
            int metadata_1,
            int metadata_2,
            string metadata_3,
            string metadata_4
        ) {
            var object = new HistoryModel ();
            object.id = id;
            object.context = context;
            object.input = input;
            object.result = result;
            object.metadata = new HistoryModelMetadata (metadata_1, metadata_2, metadata_3, metadata_4);
            return object;
        }
    }

    protected class HistoryModelMetadata {
        public int metadata_1 { get; set; }
        public int metadata_2 { get; set; }
        public string metadata_3 { get; set; }
        public string metadata_4 { get; set; }

        public HistoryModelMetadata (int m1, int m2, string m3, string m4) {
            metadata_1 = m1;
            metadata_2 = m2;
            metadata_3 = m3;
            metadata_4 = m4;
        }
    }
}
