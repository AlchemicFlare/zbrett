# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""Priority queue: BEACON > SYNC > announce > proof (TT-24)."""
from __future__ import annotations
from enum import IntEnum


class Priority(IntEnum):
    BEACON = 0
    SYNC = 1
    ANNOUNCE = 2
    PROOF = 3
