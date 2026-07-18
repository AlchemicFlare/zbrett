# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""DutyCycleInterface — RNS Interface with airtime accounting (TT-23).

Sits UNDER RNS so it sees *every* packet, including Reticulum's own traffic
(announces, path-requests, link handshakes, proofs, keepalives). Rolling 1 h
window, priority queue, delay-not-drop.
"""
from __future__ import annotations


class DutyCycleInterface:
    """Skeleton. Real impl subclasses RNS.Interface.Interface."""

    def __init__(self, duty_cycle: float = 0.01, window_s: int = 3600) -> None:
        self.duty_cycle = duty_cycle
        self.window_s = window_s

    def process_outgoing(self, data: bytes) -> None:
        raise NotImplementedError("TT-23")
