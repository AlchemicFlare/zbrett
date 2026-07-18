# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""Announce thinning (TT-25). A static hub does not need a 360 s announce."""
from __future__ import annotations


def next_announce_interval(neighbours: int, budget_used: float) -> float:
    raise NotImplementedError("TT-25")
