# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
#!/usr/bin/env bash
# TT-38 — host toolchain for the M1 measurement rig (Ubuntu 24.04).
set -euo pipefail
python3 -m pip install --upgrade rns
rnodeconf --version
echo "Attach antenna/dummy-load BEFORE plugging a board. Then: rnodeconf --autoinstall"
