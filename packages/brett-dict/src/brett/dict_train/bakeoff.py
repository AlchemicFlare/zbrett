# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""M3 compression bake-off (TT-11).

Compare brotli vs zstd --train vs token-Huffman vs raw. Metric: **5th-percentile**
compression rate (not median — the limit must survive the bad case). Also measure
decoder RAM on ESP32 and dictionary flash size. Decides the compressor AND
inline_max. If M3 is skipped: zstd is the pre-decision (migration path stays open
because the dict field is in the header anyway).
"""
from __future__ import annotations


def run_bakeoff(corpus_dir: str) -> dict:
    raise NotImplementedError("TT-11 / M3")
