# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>

class Memory:
    def __init__(self):
        self._memory = dict()
        self._memory["global"] = 0
        self._memory["sci"] = 0
        self._memory["calc"] = 0
        self._memory["prog"] = 0
        self._memory["stat"] = 0
        self._memory["date"] = 0
        self._memory["conv"] = 0

        
    def add(self, value: int | float | complex, context="global"):
        self._memory[context] += value


    def subtract(self, value: int | float | complex, context="global"):
        self._memory[context] -= value


    def recall(self, context="global"):
        return self._memory[context]
    

    def clear(self, context="global"):
        value = self._memory[context]
        self._memory[context] = 0
        return value