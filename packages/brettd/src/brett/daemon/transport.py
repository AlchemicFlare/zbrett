# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""LXMF transport binding (TT-28 hub path, TT-29 endnode vanilla, TT-30 functest).

Endnodes run standard LXMF (ecosystem compatibility). Hubs put the governor's
DutyCycleInterface under RNS.
"""
from __future__ import annotations


class Transport:
    def __init__(self, role: str) -> None:
        self.role = role

    def start(self) -> None:
        raise NotImplementedError("TT-28/29")
