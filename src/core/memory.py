# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>

"""
Contextual Memory Store
"""

from pebbles.history import HistoryViewModel

class ContextualMemory:
    """Contextual memory for storing arbitrary values for user."""

    def __init__(self, hsize=10):
        self._memory = {}
        self._history = []
        self._hsize = hsize

        for k in ["global", "sci", "calc", "prog", "stat", "conv"]:
            self._memory[k] = 0


    def add(self, value: int | float | complex, context="global"):
        """
        Add the entered value or result to the value in memory.
        """
        self._memory[context] += value


    def subtract(self, value: int | float | complex, context="global"):
        """
        Subtract the entered value or result from the value in memory.
        """
        self._memory[context] -= value


    def recall(self, context="global"):
        """
        Reveal the value in memory.
        """
        value = self._memory[context]
        if context not in ["sci", "calc"]:
            if isinstance(value, complex):
                value = float(value.imag)

            if context == "prog":
                return int(value)

        return value


    def clear(self, context="global"):
        """
        Clear memory.
        """
        value = self._memory[context]
        self._memory[context] = 0
        return value


    def push_history(self,
        answer: float | complex,
        formatted_answer: str,
        input_exp: str,
        context="sci"
    ):
        """
        Push the last answer in memory.
        """
        history_view = HistoryViewModel(context, input_exp, formatted_answer)
        history_view.to_string()
        self._history.append ({
            "answer": answer,
            "context": context,
            "view": history_view
        })


        _l = sum(1 for i in range(len(self._history)) if self._history[i]["context"] == context)
        if _l > self._hsize:
            for i in range(len(self._history)):
                if self._history[i]["context"] == context:
                    item = self._history.pop(i)
                    del item
                    break


    def get_last_ans(self, context="global"):
        """
        Fetch the last answer in memory.
        """

        value = 0
        if context == "global":
            last_item = self._history[-1]
            value = last_item["answer"]
            if last_item["context"] not in ["sci", "calc"]:
                if isinstance(value, complex):
                    value = float(value.imag)
            elif context == "prog":
                value = int(value)
        else:
            for i in range(len(self._history) - 1, 0, -1):
                if self._history[i]["context"] == context:
                    value = self._history[i]["answer"]
                    if context not in ["sci", "calc"]:
                        if isinstance(value, complex):
                            value = float(value.imag)
                    elif context == "prog":
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
