#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
#
# One-way mirror of main + tags to the public GitHub repo (EUPL-1.2).
# CI provides GITHUB_MIRROR_URL as a tokened HTTPS URL (or set GITHUB_MIRROR_TOKEN
# and GITHUB_MIRROR_REPO). Issues/PRs stay on Bitbucket/Jira; this only pushes code.
set -euo pipefail

: "${GITHUB_MIRROR_URL:?set GITHUB_MIRROR_URL (tokened https URL of the GitHub mirror)}"

git remote remove github 2>/dev/null || true
git remote add github "$GITHUB_MIRROR_URL"

# push current main and all tags, fast-forward only on the mirror side
git push github HEAD:refs/heads/main
git push github --tags
echo "mirrored main + tags -> GitHub"
