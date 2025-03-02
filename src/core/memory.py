# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>

"""
Contextual Memory Store
"""

import sqlite3
from sqlite3 import Connection, Cursor
import os
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

    def __init__(self, hsize=10):
        db_dir = os.path.join(GLib.get_user_data_dir(),
        "com.github.subhdeepjasu.pebbles")
        self._db_path = os.path.join(db_dir, "pebbles_store.db")
        print(f"DEBUG: Pebbles DB path: {self._db_path}")

        self._memory = {}
        self._history = []
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
            expected_schema = {col[0]: col[1].replace(" PRIMARY KEY AUTOINCREMENT", "").replace(" NOT NULL", "") for col in columns}

            # Ignore constraints and only compare column names and types
            if not current_schema or dict(sorted(current_schema.items())) != dict(sorted(expected_schema.items())):
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
                value = float(value.imag)

            if context == Pebbles.Context.PROGRAMMER:
                return int(value)

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


    def get_last_ans(self, context=Pebbles.Context.GLOBAL):
        """
        Fetch the last answer in memory.
        """

        value = 0
        if context == Pebbles.Context.GLOBAL:
            last_item = self._history[-1]
            value = last_item["answer"]
            if last_item["context"] not in [Pebbles.Context.SCIENTIFIC, Pebbles.Context.CALCULUS]:
                if isinstance(value, complex):
                    value = float(value.imag)
            elif context == Pebbles.Context.PROGRAMMER:
                value = int(value)
        else:
            for i in range(len(self._history) - 1, 0, -1):
                if self._history[i]["context"] == context:
                    value = self._history[i]["answer"]
                    if context not in [Pebbles.Context.SCIENTIFIC, Pebbles.Context.CALCULUS]:
                        if isinstance(value, complex):
                            value = float(value.imag)
                    elif context == Pebbles.Context.PROGRAMMER:
                        value = int(value)

                    break

        return value


    def peek(self, include_view=False):
        """
        Print the memory data.
        If `include_view` is `True`, then return all views in history.
        """
        print('Memory: ', self._memory)
        print('Last Answer: ', self._history)

        views = []
        if include_view:
            for item in self._history[::-1]:
                views.append(item["view"])

        return views


    def any(self, context='global') -> bool:
        """
        Returns `True` is anything is present in memory for the given context.
        """
        value = self._memory[context]
        if isinstance(value, complex):
            return value.imag != 0 or value.real != 0

        return value != 0
