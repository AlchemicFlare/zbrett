# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""Read-only NNTP server (TT-34): GROUP / ARTICLE / XOVER.

A thread is a DAG of 140-char nodes; the reader renders it as a tree.
"""
from __future__ import annotations


class NntpServer:
    def __init__(self, host: str = "127.0.0.1", port: int = 1119) -> None:
        self.host, self.port = host, port

    def serve_forever(self) -> None:
        raise NotImplementedError("TT-34")
