# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""LoRa time-on-air calculator (TT-27).

Real ToA from spreading factor, bandwidth and payload — the input to the
rolling-window airtime budget. Verify against the Semtech formula.
"""
from __future__ import annotations


def time_on_air_ms(payload_bytes: int, sf: int = 11, bw_hz: int = 125_000,
                   coding_rate: int = 5, preamble: int = 8) -> float:
    raise NotImplementedError("TT-27")
