# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
"""`brettd` console entry point."""
from __future__ import annotations

import argparse

from .app import BrettDaemon
from .config import Config


def main() -> int:
    parser = argparse.ArgumentParser(prog="brettd", description="zBRETT daemon")
    parser.add_argument("--role", choices=["endnode", "hub"], default="endnode")
    parser.add_argument("--config", default=None)
    args = parser.parse_args()
    daemon = BrettDaemon(Config(role=args.role, rns_config_dir=args.config))
    daemon.run()
    return 0


if __name__ == "__main__":  # pragma: no cover
    raise SystemExit(main())
