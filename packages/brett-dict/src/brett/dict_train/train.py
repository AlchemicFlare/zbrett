# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""Train the de-forum-v1 dictionary (TT-37).

Corpus: Usenet/Fido de.* dumps, posts <=300 chars. zstd --train is the
front-runner for many small payloads sharing one dictionary.
"""
from __future__ import annotations


def train(corpus_dir: str, out_path: str, dict_size: int = 8 * 1024) -> None:
    raise NotImplementedError("TT-37")
