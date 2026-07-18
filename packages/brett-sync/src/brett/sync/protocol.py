# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""SYNC_REQ / SYNC_RESP protocol (TT-21).

    A --SYNC_REQ(brett, sketch[128B], T-7d)--> B
    A <--SYNC_RESP(will={..}, send={..})----- B
On larger diffs: recurse by halving the time window (MVP §7).
"""
from __future__ import annotations


def build_sync_req(brett: bytes, window_days: int = 7) -> bytes:
    raise NotImplementedError("TT-21")
