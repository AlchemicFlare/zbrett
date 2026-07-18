# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""TCP harness for sync tests (TT-22).

Phase 2 runs the sync logic between two processes over TCP. Debugging over TCP
is far faster than over 3-second packets — correctness first, then radio.
"""
from __future__ import annotations


def run_pair(port: int = 4747) -> None:
    raise NotImplementedError("TT-22")
