# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""dag-cbor + CIDv1 codec (TT-17).

CIDv1 is a pure computation over the block — it *is* the integrity guarantee.
No Kademlia/DHT, no libp2p (MVP §4). We build the CID by hand (version + codec
+ multihash) so brett-core carries no heavy multiformats dependency; the layout
is verified against the reference implementation in the tests, so the CIDs are
genuine IPFS-interoperable CIDv1 identifiers (decision B4).
"""
from __future__ import annotations

import base64
import hashlib

# multicodec codes
DAG_CBOR = 0x71
RAW = 0x55
# multihash code
SHA2_256 = 0x12


def _uvarint(n: int) -> bytes:
    """Unsigned LEB128 varint (multiformats varint)."""
    if n < 0:
        raise ValueError("varint cannot encode a negative number")
    out = bytearray()
    while True:
        byte = n & 0x7F
        n >>= 7
        if n:
            out.append(byte | 0x80)
        else:
            out.append(byte)
            return bytes(out)


def encode_dag_cbor(node: dict) -> bytes:
    """Deterministic (canonical) dag-cbor encoding of an IPLD node.

    Uses canonical CBOR (sorted keys, shortest ints) so identical nodes always
    hash to the same CID.
    """
    import cbor2

    return cbor2.dumps(node, canonical=True)


def decode_dag_cbor(block: bytes) -> dict:
    import cbor2

    return cbor2.loads(block)


def _multihash_sha256(data: bytes) -> bytes:
    digest = hashlib.sha256(data).digest()
    return bytes([SHA2_256, len(digest)]) + digest  # 0x12 0x20 + 32 bytes


def cid_v1(block: bytes, codec: int = DAG_CBOR) -> bytes:
    """Return the raw CIDv1 bytes for a block: version | codec | multihash."""
    return b"\x01" + _uvarint(codec) + _multihash_sha256(block)


def cid_for_node(node: dict) -> bytes:
    """Encode an IPLD node to dag-cbor and return its CIDv1."""
    return cid_v1(encode_dag_cbor(node), DAG_CBOR)


def cid_to_base32(cid: bytes) -> str:
    """Human-readable CIDv1 string (multibase base32, lowercase, no padding).

    This is the canonical `bafy…` form IPFS shows.
    """
    b32 = base64.b32encode(cid).decode("ascii").lower().rstrip("=")
    return "b" + b32
