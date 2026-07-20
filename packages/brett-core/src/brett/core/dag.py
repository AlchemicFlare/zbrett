# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""Single-parent, append-only DAG store over SQLite (TT-16).

The DAG only grows — no merge, no versioning (MVP §8). Robustheit siegt (B1).
A block is keyed by its CIDv1; putting a CID that already exists is a no-op
(the "CID already local → DROP dupe" rule from the pager state machine, MVP §8).
"""
from __future__ import annotations

import sqlite3

_SCHEMA = """
CREATE TABLE IF NOT EXISTS blocks (
    cid    BLOB PRIMARY KEY,
    block  BLOB NOT NULL,
    parent BLOB,
    brett  BLOB,
    ts     INTEGER
);
CREATE INDEX IF NOT EXISTS idx_blocks_parent ON blocks(parent);
CREATE INDEX IF NOT EXISTS idx_blocks_brett  ON blocks(brett);
"""


class DagStore:
    """Append-only content-addressed block store."""

    def __init__(self, path: str = ":memory:") -> None:
        self.path = path
        self._conn = sqlite3.connect(path)
        self._conn.execute("PRAGMA journal_mode=WAL")
        self._conn.execute("PRAGMA foreign_keys=ON")
        self._conn.executescript(_SCHEMA)
        self._conn.commit()

    def put(
        self,
        cid: bytes,
        block: bytes,
        parent: bytes | None = None,
        brett: bytes | None = None,
        ts: int | None = None,
    ) -> bool:
        """Store a block. Returns True if newly inserted, False if already present.

        Append-only: an existing CID is left untouched (idempotent, dedup).
        """
        cur = self._conn.execute(
            "INSERT OR IGNORE INTO blocks(cid, block, parent, brett, ts) VALUES (?,?,?,?,?)",
            (cid, block, parent, brett, ts),
        )
        self._conn.commit()
        return cur.rowcount == 1

    def has(self, cid: bytes) -> bool:
        return self._conn.execute("SELECT 1 FROM blocks WHERE cid=?", (cid,)).fetchone() is not None

    def get(self, cid: bytes) -> bytes | None:
        row = self._conn.execute("SELECT block FROM blocks WHERE cid=?", (cid,)).fetchone()
        return row[0] if row else None

    def children(self, cid: bytes) -> list[bytes]:
        """CIDs whose single parent is `cid` (thread replies)."""
        rows = self._conn.execute("SELECT cid FROM blocks WHERE parent=?", (cid,)).fetchall()
        return [r[0] for r in rows]

    def roots(self, brett: bytes | None = None) -> list[bytes]:
        """Thread roots (no parent), optionally scoped to a brett."""
        if brett is None:
            rows = self._conn.execute("SELECT cid FROM blocks WHERE parent IS NULL").fetchall()
        else:
            rows = self._conn.execute(
                "SELECT cid FROM blocks WHERE parent IS NULL AND brett=?", (brett,)
            ).fetchall()
        return [r[0] for r in rows]

    def count(self, brett: bytes | None = None) -> int:
        if brett is None:
            return self._conn.execute("SELECT COUNT(*) FROM blocks").fetchone()[0]
        row = self._conn.execute("SELECT COUNT(*) FROM blocks WHERE brett=?", (brett,)).fetchone()
        return row[0]

    def close(self) -> None:
        self._conn.close()

    def __enter__(self) -> DagStore:
        return self

    def __exit__(self, *exc: object) -> None:
        self.close()
