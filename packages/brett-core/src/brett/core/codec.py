# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""dag-cbor + CIDv1 codec (TT-17).

CIDv1 is a pure computation over the block — it *is* the integrity guarantee.
No Kademlia/DHT, no libp2p (MVP §4).
"""
from __future__ import annotations


def encode_dag_cbor(obj: dict) -> bytes:
    """Deterministic dag-cbor encoding of an IPLD node."""
    raise NotImplementedError("TT-17")


def cid_v1(block: bytes) -> bytes:
    """Return the 32-byte CIDv1 digest for a raw block."""
    raise NotImplementedError("TT-17")
