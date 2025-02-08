# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>

"""
Contextual Memory Store
"""

class ContextualMemory:
    """Contextual memory for storing arbitrary values for user."""

    def __init__(self):
        self._memory = {}
        self._last_ans = {}

        for k in ["global", "sci", "calc", "prog", "stat", "conv"]:
            self._memory[k] = 0
            self._last_ans[k] = 0


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


    def set_last_ans(self, value: float | complex, context="global"):
        """
        Save the last answer in memory.
        """
        self._last_ans[context] = value
        if context != "global":
            self._last_ans["global"] = value


    def get_last_ans(self, context="global"):
        """
        Fetch the last answer in memory.
        """
        value = self._last_ans[context]

        if context not in ["sci", "calc"]:
            if isinstance(value, complex):
                value = float(value.imag)

            if context == "prog":
                return int(value)

        return value


    def peek(self):
        """
        Print the memory data.
        """
        print('Memory: ', self._memory)
        print('Last Answer: ', self._last_ans)


    def any(self, context='global') -> bool:
        """
        Returns True is anything is present in memory for the given context.
        """
        value = self._memory[context]
        if isinstance(value, complex):
            return value.imag != 0 or value.real != 0

        return value != 0
