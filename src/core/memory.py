# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>

"""
Contextual Memory Store
"""

import sqlite3
import os
from sqlite3 import Connection, Cursor
from gi.repository import Pebbles, GLib

class ContextualMemory:
    """Contextual memory for storing arbitrary values for user."""

    SCHEMA = {
        "history": [
            ("id", "INTEGER PRIMARY KEY AUTOINCREMENT"),
            ("context", "TEXT NOT NULL"),
            ("input", "TEXT NOT NULL"),
            ("result", "TEXT NOT NULL"),
            ("metadata_1", "INTEGER"),    # Angle Mode, Word Length, Series Index
            ("metadata_2", "INTEGER"),    # Number System
            ("metadata_3", "TEXT"),       # Series CSV
            ("metadata_4", "TEXT"),       # Dataset Hash
        ]
    }

    HISTORY_INSERT_QUERY = """
        INSERT INTO history (context, input, result, metadata_1, metadata_2, metadata_3, metadata_4)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    """

    HISTORY_LAST_RESULT_QUERY = """
        SELECT result, context FROM history
         ORDER BY id DESC
         LIMIT 1
    """

    HISTORY_CONTEXTUAL_LAST_RESULT_QUERY = """
        SELECT result, context FROM history
         WHERE context = ?
         ORDER BY id DESC
         LIMIT 1
    """

    HISTORY_VIEW_QUERY = """
        SELECT id, input, result
          FROM history
         WHERE context = ?
    """

    HISTORY_VIEW_ID_SEARCH_QUERY = """
        SELECT * FROM history
         WHERE id = ?
         LIMIT 1
    """

    def __init__(self, hsize=10):
        db_dir = os.path.join(GLib.get_user_data_dir(),
        "com.github.subhadeepjasu.pebbles")
        self._db_path = os.path.join(db_dir, "pebbles_store.db")
        print(f"DEBUG: Pebbles DB path: {self._db_path}")

        self._memory = {}
        self._hsize = hsize

        for k in [
            Pebbles.Context.GLOBAL,
            Pebbles.Context.SCIENTIFIC,
            Pebbles.Context.CALCULUS,
            Pebbles.Context.PROGRAMMER,
            Pebbles.Context.STATISTICS]:
            self._memory[k] = 0

        self._initialize_database(db_dir)


    def _initialize_database(self, db_dir:str):
        first_time_setup = not os.path.exists(self._db_path)  # Check if DB exists
        os.makedirs(db_dir, exist_ok=True)
        conn = sqlite3.connect(self._db_path)

        if first_time_setup or not self._schema_matches(conn):
            print("DEBUG: Initializing database (first-time setup or schema mismatch)...")
            self._reset_database(conn)

        conn.close()


    def _get_current_schema(self, conn:Connection, table_name:str):
        cursor = conn.cursor()
        cursor.execute(f"PRAGMA table_info({table_name})")
        return {row[1]: row[2] for row in cursor.fetchall()}


    def _schema_matches(self, conn: Connection):
        for table, columns in ContextualMemory.SCHEMA.items():
            current_schema = self._get_current_schema(conn, table)
            expected_schema = {col[0]: col[1].replace(" PRIMARY KEY AUTOINCREMENT", "")
                               .replace(" NOT NULL", "") for col in columns}

            # Ignore constraints and only compare column names and types
            if not current_schema or dict(sorted(current_schema.items())) != \
                dict(sorted(expected_schema.items())):
                print(f"DEBUG: Schema mismatch detected for {table}!")
                return False
        return True


    def _reset_database(self, conn: Connection):
        cursor = conn.cursor()

        for table in ContextualMemory.SCHEMA:
            cursor.execute(f"DROP TABLE IF EXISTS {table};")

        for table, columns in ContextualMemory.SCHEMA.items():
            column_definitions = ", ".join(f"{col[0]} {col[1]}" for col in columns)
            cursor.execute(f"CREATE TABLE {table} ({column_definitions})")

        self._setup_history_limit_trigger(cursor)
        conn.commit()


    def _setup_history_limit_trigger(self, cursor:Cursor, group_col='context'):
        trigger_setup_query = f"""
            CREATE TRIGGER IF NOT EXISTS limit_history
            AFTER INSERT ON history
            WHEN (SELECT COUNT(*) FROM history WHERE {group_col} = NEW.{group_col}) > {self._hsize}
            BEGIN
                DELETE FROM history WHERE id IN (
                    SELECT id FROM history
                    WHERE {group_col} = NEW.{group_col}
                    ORDER BY id ASC
                    LIMIT (SELECT COUNT(*) FROM history WHERE context = NEW.context) - {self._hsize}
                );
            END;
        """
        cursor.execute(trigger_setup_query)


    def add(self, value: int | float | complex, context=Pebbles.Context.GLOBAL):
        """
        Add the entered value or result to the value in memory.
        """
        self._memory[context] += value


    def subtract(self, value: int | float | complex, context=Pebbles.Context.GLOBAL):
        """
        Subtract the entered value or result from the value in memory.
        """
        self._memory[context] -= value


    def recall(self, context=Pebbles.Context.GLOBAL):
        """
        Reveal the value in memory.
        """
        value = self._memory[context]
        if context not in [Pebbles.Context.SCIENTIFIC, Pebbles.Context.CALCULUS]:
            if isinstance(value, complex):
                value = float(value.real)
            elif context == Pebbles.Context.PROGRAMMER:
                value = int(value)

        return value


    def clear(self, context=Pebbles.Context.GLOBAL):
        """
        Clear memory.
        """
        value = self._memory[context]
        self._memory[context] = 0
        return value


    def push_history(self,
        context: str,
        input_exp: str,
        result: str,
        metadata:dict
    ):
        """
        Push the last result in memory.
        """
        if input_exp.strip() in ['', '0']:
            return

        try:
            if float(input_exp.strip()) == 0.0:
                return
        except ValueError:
            pass

        metadata_1 = metadata['metadata_1'] if 'metadata_1' in metadata else 0
        metadata_2 = metadata['metadata_2'] if 'metadata_2' in metadata else 0
        metadata_3 = metadata['metadata_3'] if 'metadata_3' in metadata else ''
        metadata_4 = metadata['metadata_4'] if 'metadata_4' in metadata else ''
        conn = sqlite3.connect(self._db_path)
        cursor = conn.cursor()
        cursor.execute(ContextualMemory.HISTORY_INSERT_QUERY, (
            context,
            input_exp,
            result,
            metadata_1,
            metadata_2,
            metadata_3,
            metadata_4
        ))

        conn.commit()
        conn.close()


    def get_last_result(self, context=Pebbles.Context.GLOBAL):
        """
        Fetch the last result in history table.
        """
        conn = sqlite3.connect(self._db_path)
        cursor = conn.cursor()
        if context == Pebbles.Context.GLOBAL:
            cursor.execute(ContextualMemory.HISTORY_LAST_RESULT_QUERY)
        else:
            cursor.execute(ContextualMemory.HISTORY_CONTEXTUAL_LAST_RESULT_QUERY, (context,))

        last_entry = cursor.fetchone()
        conn.close()
        return last_entry[0] if last_entry else None


    def peek(self):
        """
        Print the memory data.
        """
        print('Memory: ', self._memory)


    def get_views(self, format_func:callable, context=Pebbles.Context.SCIENTIFIC):
        """
        Fetches all history in a list of views by context.
        """
        conn = sqlite3.connect(self._db_path)
        cursor = conn.cursor()
        cursor.execute(ContextualMemory.HISTORY_VIEW_QUERY, (context,))
        history_entries = cursor.fetchall()
        if format_func is not None:
            views = [Pebbles.HistoryModel.new_for_view(id, context, inp, format_func(res))
                     for id, inp, res in history_entries]
        else:
            views = [Pebbles.HistoryModel.new_for_view(id, context, inp, res)
                     for id, inp, res in history_entries]
        conn.close()
        return views


    def get_history_by_id(self, item_id:int):
        """
        Gets the history data by id.
        """
        conn = sqlite3.connect(self._db_path)
        cursor = conn.cursor()
        cursor.execute(ContextualMemory.HISTORY_VIEW_ID_SEARCH_QUERY, (item_id,))
        history_item = Pebbles.HistoryModel.new_from_db_response(*cursor.fetchone())
        conn.close()
        return history_item


    def any(self, context='global') -> bool:
        """
        Returns `True` is anything is present in memory for the given context.
        """
        value = self._memory[context]
        if isinstance(value, complex):
            return value.imag != 0 or value.real != 0

        return value != 0
