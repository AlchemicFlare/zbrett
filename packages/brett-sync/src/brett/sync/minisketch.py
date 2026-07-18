# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""ctypes wrapper around libminisketch (TT-20).

No fair binding exists upstream; ~200 lines. Loaded via ctypes.CDLL.
"""
from __future__ import annotations

SKETCH_CAPACITY = 8       # entries reconstructable from a 128 B sketch
SKETCH_BYTES = 128


class Minisketch:
    def __init__(self, capacity: int = SKETCH_CAPACITY) -> None:
        self.capacity = capacity

    def add(self, element: int) -> None:
        raise NotImplementedError("TT-20")

    def merge_decode(self, other: "Minisketch") -> list[int]:
        raise NotImplementedError("TT-20")
