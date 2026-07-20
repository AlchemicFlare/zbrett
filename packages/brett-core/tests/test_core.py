# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""brett-core tests (TT-16..19). Includes a cross-check of our hand-built CIDv1
against the reference `multiformats` library to guarantee IPFS interop."""
from __future__ import annotations

import pytest

from brett.core import codec, dag, dictionary, policy, wire
from brett.core.wire import Beacon, Inline


# ---- codec / CIDv1 ------------------------------------------------------------
def test_cid_structure():
    c = codec.cid_v1(b"hello", codec.RAW)
    assert c[0] == 0x01  # CIDv1
    assert c[1] == codec.RAW  # multicodec
    assert c[2] == 0x12 and c[3] == 0x20  # sha2-256, 32 bytes
    assert len(c) == 4 + 32


def test_cid_deterministic_and_dagcbor_len():
    node = {"b": b"\xa3\xf1", "t": 29184301, "x": b"teaser"}
    a = codec.cid_for_node(node)
    b = codec.cid_for_node(node)
    assert a == b
    assert len(a) == wire.CID_LEN  # 36 bytes for dag-cbor + sha2-256


def test_cid_base32_roundtrip():
    s = codec.cid_to_base32(codec.cid_for_node({"hello": "welt"}))
    assert s.startswith("bafy")  # dag-cbor CIDv1 base32 prefix


@pytest.mark.parametrize("block", [b"", b"hello", b"\x00\x01\x02", bytes(range(256))])
def test_cid_matches_multiformats_reference(block):
    """Our minimal CIDv1 must equal the reference implementation, byte for byte."""
    pytest.importorskip("multiformats")
    from multiformats import CID, multihash

    mh = multihash.digest(block, "sha2-256")
    for our_codec, name in [(codec.RAW, "raw"), (codec.DAG_CBOR, "dag-cbor")]:
        ref = CID("base32", 1, name, mh)
        ours = codec.cid_v1(block, our_codec)
        assert ours == bytes(ref), f"{name}: {ours.hex()} != {bytes(ref).hex()}"
        assert codec.cid_to_base32(ours) == str(ref)


def test_dagcbor_canonical_roundtrip():
    node = {"z": 1, "a": 2, "m": b"\x00"}
    block = codec.encode_dag_cbor(node)
    assert codec.decode_dag_cbor(block) == node
    # canonical: key order in the encoding must not depend on insertion order
    assert codec.encode_dag_cbor({"a": 2, "m": b"\x00", "z": 1}) == block


# ---- DAG store ----------------------------------------------------------------
def test_dag_put_has_get():
    d = dag.DagStore()
    block = b"a post"
    cid = codec.cid_v1(block, codec.RAW)
    assert d.put(cid, block, brett=b"\xa3\xf1") is True
    assert d.has(cid)
    assert d.get(cid) == block
    assert d.get(b"nope") is None


def test_dag_append_only_dedup():
    d = dag.DagStore()
    cid = codec.cid_v1(b"x", codec.RAW)
    assert d.put(cid, b"x") is True
    assert d.put(cid, b"x-tampered") is False  # dupe ignored, original kept
    assert d.get(cid) == b"x"
    assert d.count() == 1


def test_dag_threading():
    d = dag.DagStore()
    root = codec.cid_v1(b"root", codec.RAW)
    reply = codec.cid_v1(b"reply", codec.RAW)
    d.put(root, b"root", parent=None, brett=b"B")
    d.put(reply, b"reply", parent=root, brett=b"B")
    assert d.children(root) == [reply]
    assert d.roots(brett=b"B") == [root]
    assert d.count(brett=b"B") == 2


def test_dag_persists_to_disk(tmp_path):
    p = str(tmp_path / "dag.sqlite")
    cid = codec.cid_v1(b"persist", codec.RAW)
    with dag.DagStore(p) as d:
        d.put(cid, b"persist")
    with dag.DagStore(p) as d2:
        assert d2.get(cid) == b"persist"


# ---- policy -------------------------------------------------------------------
def _beacon(size):
    return Beacon(
        brett=b"B", content=b"c", parent=None, author=b"aaaa", ts=1, size=size, teaser=b"t"
    )


def _inline():
    return Inline(brett=b"B", parent=None, author=b"aaaa", ts=1, body=b"hi")


def test_policy_inline_only_rejects_beacon():
    pol = policy.BrettPolicy(brett="/DE/COMP/MESH/CHAT", accept_inline=True, accept_beacon=False)
    assert policy.enforce(pol, _inline()) is True
    assert policy.enforce(pol, _beacon(100)) is False


def test_policy_beacon_max_size():
    pol = policy.BrettPolicy(brett="/DE/SCI/PAPERS", accept_beacon=True, max_size=512_000)
    assert policy.enforce(pol, _beacon(400_000)) is True
    assert policy.enforce(pol, _beacon(600_000)) is False


def test_policy_check_raises():
    pol = policy.BrettPolicy(brett="/x", accept_inline=False)
    with pytest.raises(policy.PolicyViolation):
        policy.check(pol, _inline())


# ---- dictionary ---------------------------------------------------------------
def test_dict_resolve_and_bounds():
    allow = [b"cid-v1", b"cid-v2", None]
    assert dictionary.resolve_dict_cid(allow, 1) == b"cid-v2"
    with pytest.raises(KeyError):
        dictionary.resolve_dict_cid(allow, 2)  # nulled slot
    with pytest.raises(ValueError):
        dictionary.resolve_dict_cid(allow, 16)  # beyond 4 bits


def test_dict_pack_unpack():
    for idx in range(16):
        assert dictionary.unpack_index(dictionary.pack_index(idx, flags=0)) == (idx, 0)
    assert dictionary.unpack_index(dictionary.pack_index(5, flags=3)) == (5, 3)
