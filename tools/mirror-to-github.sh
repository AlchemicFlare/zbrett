#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
#
# One-way mirror of main + tags to the public GitHub repo (EUPL-1.2), over SSH.
#
# Auth: an ED25519 deploy key (GitHub rejects RSA-SHA1). Provide the PRIVATE key
# base64-encoded in the SECURED repo variable GITHUB_DEPLOY_KEY; register its
# PUBLIC half as a WRITE deploy key on the GitHub repo. Locally (no variable set)
# it falls back to your own SSH agent.
set -euo pipefail

GITHUB_MIRROR_URL="${GITHUB_MIRROR_URL:-git@github.com:AlchemicFlare/zbrett.git}"
IN_CI="${BITBUCKET_BUILD_NUMBER:-}"

if [ -n "${GITHUB_DEPLOY_KEY:-}" ]; then
  echo "▶ GITHUB_DEPLOY_KEY present — installing ED25519 deploy key"
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  # tolerate wrapped/space-padded base64 from the repo-variable UI
  printf '%s' "$GITHUB_DEPLOY_KEY" | tr -d '[:space:]' | base64 -d > ~/.ssh/id_mirror
  chmod 600 ~/.ssh/id_mirror
  if ! ssh-keygen -y -f ~/.ssh/id_mirror >/tmp/id_mirror.pub 2>/tmp/keyerr; then
    echo "✖ GITHUB_DEPLOY_KEY did not decode to a valid private key:"; cat /tmp/keyerr
    echo "  → re-encode with:  base64 -w0 zbrett-mirror   (must be the PRIVATE key)"; exit 1
  fi
  echo "▶ Loaded key fingerprint (must match a WRITE deploy key on GitHub):"
  ssh-keygen -lf /tmp/id_mirror.pub
  ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts 2>/dev/null || true
  export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_mirror -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
elif [ -n "$IN_CI" ]; then
  echo "✖ Running in CI but GITHUB_DEPLOY_KEY is not set."
  echo "  → Bitbucket → Repo settings → Repository variables → add GITHUB_DEPLOY_KEY (Secured),"
  echo "    value = base64 of the ED25519 PRIVATE key whose PUBLIC half is a write deploy key on GitHub."
  exit 1
else
  echo "▶ No GITHUB_DEPLOY_KEY — using your local SSH agent."
fi

# Auth probe: GitHub returns exit 1 with a greeting on success — surface it, don't fail on it.
echo "▶ SSH auth probe to GitHub:"
ssh -o StrictHostKeyChecking=accept-new ${GIT_SSH_COMMAND:+-i "$HOME/.ssh/id_mirror" -o IdentitiesOnly=yes} -T git@github.com 2>&1 | sed 's/^/    /' || true

git remote remove github 2>/dev/null || true
git remote add github "$GITHUB_MIRROR_URL"
git push github HEAD:refs/heads/main
git push github --tags
echo "✔ mirrored main + tags -> GitHub"
