# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""BEACON / INLINE wire-format constants and dataclasses (MVP §5).

The mesh carries the *existence claim*, not the payload. Two message types,
two economies. Sizes are post-compression byte budgets at SF11 (1 packet).
"""
from __future__ import annotations

from dataclasses import dataclass

CID_LEN = 36  # full CIDv1 (dag-cbor, sha2-256): 0x01 0x71 0x12 0x20 + 32-byte digest
BEACON_BYTES = 108  # teaser + CID, 1 packet
INLINE_BYTES = 76  # body IS the block, no content-CID

# inline_max (characters BEFORE compression) is derived from M3 — see brett-dict.
INLINE_MAX_CHARS: int | None = None

# dag-cbor keys for the BEACON node (MVP §5). Short keys keep the CBOR small.
BEACON_KEYS = ("b", "c", "p", "a", "t", "s", "x")


@dataclass(slots=True)
class Beacon:
    """A claim that a post exists — carried over the mesh."""

    brett: bytes  # b: brett id
    content: bytes  # c: CIDv1 content address (full, IPFS-compatible)
    parent: bytes | None  # p: CIDv1 of the single parent (None = thread root)
    author: bytes  # a: 4-byte author prefix
    ts: int  # t: minute-resolution timestamp
    size: int  # s: size hint for the full content
    teaser: bytes  # x: ~28-byte compressed teaser

    def to_node(self) -> dict:
        """Map to the dag-cbor node (short keys, MVP §5)."""
        return {
            "b": self.brett,
            "c": self.content,
            "p": self.parent,
            "a": self.author,
            "t": self.ts,
            "s": self.size,
            "x": self.teaser,
        }


@dataclass(slots=True)
class Inline:
    """A short post whose body *is* the block — cheaper than a BEACON."""

    brett: bytes
    parent: bytes | None
    author: bytes
    ts: int
    body: bytes  # the content itself (<= inline_max, post-compression)
