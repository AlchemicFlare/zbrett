# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""Wantlist + fetch logic (TT-31).

Risk: 3 months without fat-net = thousands of CIDs. Needs prioritisation + decay.
"""
from __future__ import annotations


class Wantlist:
    def add(self, cid: bytes) -> None:
        raise NotImplementedError("TT-31")
