# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""BEACON / INLINE wire-format constants and dataclasses (MVP §5).

The mesh carries the *existence claim*, not the payload. Two message types,
two economies. Sizes are post-compression byte budgets at SF11 (1 packet).
"""
from __future__ import annotations

from dataclasses import dataclass

CID_LEN = 32          # full CIDv1, IPFS-interop (decision B4)
BEACON_BYTES = 108    # teaser + CID, 1 packet
INLINE_BYTES = 76     # body IS the block, no content-CID

# inline_max (characters BEFORE compression) is derived from M3 — see brett-dict.
INLINE_MAX_CHARS: int | None = None


@dataclass(slots=True)
class Beacon:
    brett: bytes      # b: 2B brett id
    content: bytes    # c: CID(32) content address
    parent: bytes     # p: CID(32) single parent
    author: bytes     # a: 4B author prefix
    ts: int           # t: minute-resolution timestamp
    size: int         # s: size hint
    teaser: bytes     # x: ~28B brotli/zstd teaser


@dataclass(slots=True)
class Inline:
    brett: bytes
    parent: bytes
    author: bytes
    ts: int
    body: bytes       # the block itself
