# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""Dictionary index handling (TT-19).

A dictionary is a content-addressed IPLD object, not a registry enum. Messages
carry a 4-bit index into the policy's append-only `dict_allow[]`. 4 bits against
a whole class of migration-data-loss bugs (MVP §6.2). Slots are append-only.
"""
from __future__ import annotations

DICT_INDEX_BITS = 4
MAX_DICT_SLOTS = 2 ** DICT_INDEX_BITS


def resolve_dict_cid(dict_allow: list[bytes], index: int) -> bytes:
    if not 0 <= index < len(dict_allow):
        raise IndexError("dict index outside dict_allow")
    return dict_allow[index]
