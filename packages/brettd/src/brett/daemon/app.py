# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""Role wiring and lifecycle for brettd."""
from __future__ import annotations

from .config import Config


class BrettDaemon:
    def __init__(self, config: Config) -> None:
        self.config = config

    def run(self) -> None:
        # Hub role additionally loads brett.governor.DutyCycleInterface.
        raise NotImplementedError("E5")
