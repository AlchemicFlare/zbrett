# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""Single-parent, append-only DAG store over SQLite (TT-16).

The DAG only grows — no merge, no versioning (MVP §8). Robustheit siegt (B1).
"""
from __future__ import annotations


class DagStore:
    def __init__(self, path: str = ":memory:") -> None:
        self.path = path

    def put(self, cid: bytes, block: bytes, parent: bytes | None) -> None:
        raise NotImplementedError("TT-16")

    def has(self, cid: bytes) -> bool:
        raise NotImplementedError("TT-16")
