# Contributing to zBRETT

## Workflow
Solo/trunk: integrate directly on `main`. Run the local gate before pushing.
See `scripts/README.md` (git-bitbucket dev-scripts): `dev-sync`, `dev-ship`, `dev-doctor`.

```powershell
.\scripts\precheck.ps1      # lint + tests + reuse lint
.\scripts\dev-ship.ps1      # precheck, commit, push (ff-only)
```

## Every source file carries a licence header
```
# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
```
`uv run reuse lint` must pass. New third-party code must be EUPL-1.2 compatible
(permissive is always fine; copyleft only per the EUPL §5 compatibility list).

## Commits
Conventional-ish, reference the Jira issue: `E2/TT-17: add CIDv1 encoder`.

## Wire format is shared and still moving
`brett.core.wire` and `brett.core.policy` are the contract every other package
depends on. Changing them is an ADR-worthy event — coordinate, don't fork.
