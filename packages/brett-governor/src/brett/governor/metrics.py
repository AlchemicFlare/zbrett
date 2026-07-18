# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""Prometheus metrics (TT-26) — without these, blind in the field."""
from __future__ import annotations


def start_exporter(port: int = 9187) -> None:
    raise NotImplementedError("TT-26")
