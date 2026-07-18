# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""IPFS fetch via the Kubo HTTP API (TT-32)."""
from __future__ import annotations


async def fetch_block(cid: bytes, api_url: str = "http://127.0.0.1:5001") -> bytes:
    raise NotImplementedError("TT-32")
