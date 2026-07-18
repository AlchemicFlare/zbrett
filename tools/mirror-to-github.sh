#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
#
# One-way mirror of main + tags to the public GitHub repo (EUPL-1.2).
# Default remote is the SSH mirror git@github.com:AlchemicFlare/zbrett.git; override
# with GITHUB_MIRROR_URL. Auth is via SSH key (local: your agent; CI: Pipelines SSH key
# + a GitHub write deploy key). Issues/PRs stay on Bitbucket/Jira; this only pushes code.
set -euo pipefail

GITHUB_MIRROR_URL="${GITHUB_MIRROR_URL:-git@github.com:AlchemicFlare/zbrett.git}"

git remote remove github 2>/dev/null || true
git remote add github "$GITHUB_MIRROR_URL"

# push current main and all tags, fast-forward only on the mirror side
git push github HEAD:refs/heads/main
git push github --tags
echo "mirrored main + tags -> GitHub"
