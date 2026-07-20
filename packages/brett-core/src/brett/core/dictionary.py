# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""Dictionary index handling (TT-19).

A dictionary is a content-addressed IPLD object, not a registry enum. Messages
carry a 4-bit index into the policy's append-only ``dict_allow[]``. 4 bits
against a whole class of migration-data-loss bugs (MVP §6.2). Slots are
append-only: streak a slot by nulling it, never reorder — otherwise old messages
are silently reinterpreted.
"""
from __future__ import annotations

DICT_INDEX_BITS = 4
MAX_DICT_SLOTS = 2**DICT_INDEX_BITS  # 16


def resolve_dict_cid(dict_allow: list[bytes | None], index: int) -> bytes:
    """Resolve a 4-bit dictionary index to its CID via the policy's dict_allow."""
    if not 0 <= index < MAX_DICT_SLOTS:
        raise ValueError(f"dict index {index} outside 0..{MAX_DICT_SLOTS - 1}")
    if index >= len(dict_allow) or dict_allow[index] is None:
        raise KeyError(f"dict slot {index} is empty")
    return dict_allow[index]  # type: ignore[return-value]


def pack_index(dict_index: int, flags: int = 0) -> int:
    """Pack the 4-bit dict index into the low nibble of a header byte."""
    if not 0 <= dict_index < MAX_DICT_SLOTS:
        raise ValueError("dict index out of range")
    if not 0 <= flags < MAX_DICT_SLOTS:
        raise ValueError("flags nibble out of range")
    return (flags << DICT_INDEX_BITS) | dict_index


def unpack_index(header: int) -> tuple[int, int]:
    """Return (dict_index, flags) from a packed header byte."""
    return header & (MAX_DICT_SLOTS - 1), (header >> DICT_INDEX_BITS) & (MAX_DICT_SLOTS - 1)
