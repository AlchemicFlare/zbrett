# ADR-0001 — One monorepo, governor split later

**Status:** accepted (2026-07-18)

## Context
Eight software/hardware epics (TT E1–E8) produce several Python components that
share one wire format (`brett.core.wire`) and policy schema — and that contract
is *still moving* (`inline_max` isn't fixed until M3/TT-11). The team is
effectively solo/trunk. Existing tooling (`repos.psd1`, git-bitbucket scripts)
already refreshes multiple sibling repos under `C:\Dev`.

## Decision
Keep **all BRETT code in one `uv`-workspace monorepo `zbrett`**
(`git@bitbucket.org:precisyn/zbrett.git`), a sibling of `website/` inside
`C:\Dev\dasBRETT`. Packages: core, sync, governor, fettnetz, brettd, nntp, dict.
Measurements and deploy assets live in the same repo.

**Exceptions kept separate:**
- `xbrett-website` — different lifecycle (Netlify), different audience.
- **RNode firmware** — external upstream (`markqvist/RNode_Firmware`, GPLv3). Only
  fork if a board port (T-Deck / ThinkNode) is needed; a fork is its own repo.
- **Dictionary corpus** — data, not source; gitignored, published to IPFS by CID.

**Planned split:** `brett-governor` (the DutyCycleInterface) has standalone value
to the Reticulum community and is the candidate to move to its own repo and be
upstreamed once stable. It is therefore isolated now: it depends only on `rns` +
`prometheus-client`, never on `brett-core`.

## Consequences
+ One atomic change touches the wire format and every consumer — no cross-repo
  version dance during MVP (the exact data-loss failure the spec warns about).
+ One entry in `repos.psd1`; one `uv sync`.
− The repo mixes libraries, an app, measurements and ops. Mitigated by the
  `packages/` boundary and per-package `pyproject.toml`.
