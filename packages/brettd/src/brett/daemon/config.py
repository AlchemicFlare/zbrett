# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""brettd configuration (role, interfaces, subscribed bretter)."""
from __future__ import annotations

from dataclasses import dataclass, field


@dataclass(slots=True)
class Config:
    role: str = "endnode"          # "endnode" | "hub"
    bretter: list[str] = field(default_factory=list)
    rns_config_dir: str | None = None
