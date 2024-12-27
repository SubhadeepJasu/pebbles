# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>

class ContextualMemory:
    """Contextual memory for storing arbitrary values for user."""

    def __init__(self):
        self._memory = dict()
        self._last_ans = dict()

        for k in ["global", "sci", "calc", "prog", "stat", "conv"]:
            self._memory[k] = 0
            self._last_ans[k] = 0


    def add(self, value: int | float | complex, context="global"):
        self._memory[context] += value


    def subtract(self, value: int | float | complex, context="global"):
        self._memory[context] -= value


    def recall(self, context="global"):
        value = self._memory[context]
        if context not in ["sci", "calc"]:
            if type(value) == complex:
                value = float(value.imag)

            if context == "prog":
                return int(value)

        return value

    def clear(self, context="global"):
        value = self._memory[context]
        self._memory[context] = 0
        return value


    def set_last_ans(self, value: float | complex, context="global"):
        self._last_ans[context] = value
        if context != "global":
            self._last_ans["global"] = value


    def get_last_ans(self, context="global"):
        value = self._last_ans[context]

        if context not in ["sci", "calc"]:
            if type(value) == complex:
                value = float(value.imag)

            if context == "prog":
                return int(value)

        return value


    def peek(self):
        print('Memory: ', self._memory)
        print('Last Answer: ', self._last_ans)


    def any(self, context='global') -> bool:
        value = self._memory[context]
        if type(value) == complex:
            return value.imag != 0 or value.real != 0

        return value != 0
