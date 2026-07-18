#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
#
# One-way mirror of main + tags to the public GitHub repo (EUPL-1.2), over SSH.
#
# Auth: an ED25519 deploy key (GitHub rejects RSA-SHA1, which is all Bitbucket's
# Pipelines SSH-keys feature can generate). Provide the PRIVATE key base64-encoded
# in the secured repo variable GITHUB_DEPLOY_KEY; register its PUBLIC half as a
# WRITE deploy key on the GitHub repo. Locally (no variable set) it falls back to
# your own SSH agent. Issues/PRs stay on Bitbucket/Jira; this only pushes code.
set -euo pipefail

GITHUB_MIRROR_URL="${GITHUB_MIRROR_URL:-git@github.com:AlchemicFlare/zbrett.git}"

# CI path: materialise the ED25519 deploy key and use ONLY it (IdentitiesOnly),
# so a rejected RSA agent key is never offered to GitHub.
if [ -n "${GITHUB_DEPLOY_KEY:-}" ]; then
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  echo "$GITHUB_DEPLOY_KEY" | base64 -d > ~/.ssh/id_mirror
  chmod 600 ~/.ssh/id_mirror
  ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts 2>/dev/null || true
  export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_mirror -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
fi

git remote remove github 2>/dev/null || true
git remote add github "$GITHUB_MIRROR_URL"

git push github HEAD:refs/heads/main
git push github --tags
echo "mirrored main + tags -> GitHub"
