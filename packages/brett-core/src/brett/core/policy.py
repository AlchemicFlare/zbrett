# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""Brett policy: the declared economy of a board + enforcement (TT-18).

A Brett declares which message types it accepts and the ceilings that apply
(MVP §2). The node checks incoming messages against it — a violation is a drop,
never a relay. The physics sanction, not the police; the policy only draws the
line the physics then enforce.
"""
from __future__ import annotations

from dataclasses import dataclass

from .wire import Beacon, Inline


@dataclass(slots=True)
class BrettPolicy:
    brett: str
    accept_inline: bool = True
    accept_beacon: bool = False
    max_size: int | None = None  # ceiling for BEACON-referenced content, bytes
    beacon_quota: int | None = None  # BEACONs per author per day (None = unlimited)
    retain: str = "180d"  # "<n>d" | "pinned"


class PolicyViolation(Exception):
    """Raised by ``check`` when a message is inadmissible under the policy."""


def enforce(policy: BrettPolicy, message: Beacon | Inline) -> bool:
    """Return True if the message is admissible under the policy, else False."""
    if isinstance(message, Inline):
        return policy.accept_inline
    if isinstance(message, Beacon):
        if not policy.accept_beacon:
            return False
        if policy.max_size is not None and message.size > policy.max_size:
            return False
        return True
    raise TypeError(f"not a wire message: {type(message)!r}")


def check(policy: BrettPolicy, message: Beacon | Inline) -> None:
    """Like ``enforce`` but raises :class:`PolicyViolation` on rejection."""
    if not enforce(policy, message):
        raise PolicyViolation(f"{type(message).__name__} rejected by policy for {policy.brett}")
