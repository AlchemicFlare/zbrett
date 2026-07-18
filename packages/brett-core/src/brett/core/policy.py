# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""Brett policy: signed IPLD object + enforcement (TT-18).

A Brett declares its economy (accept INLINE/BEACON, max_size, quotas, retention).
Violation = drop, never relay (MVP §2). The physics sanction, not the police.
"""
from __future__ import annotations

from dataclasses import dataclass


@dataclass(slots=True)
class BrettPolicy:
    brett: str
    accept_inline: bool = True
    accept_beacon: bool = False
    max_size: int | None = None
    retain: str = "180d"


def enforce(policy: BrettPolicy, message: object) -> bool:
    """Return True if the message is admissible under the policy."""
    raise NotImplementedError("TT-18")
