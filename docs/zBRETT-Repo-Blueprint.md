# zBRETT — Repository Organization Blueprint

**Status:** accepted · **Date:** 2026-07-18 · **Owner:** protagx · **Jira:** [TT](https://precisyn.atlassian.net/jira/software/projects/TT) · **Concept:** Confluence Space P

This is the scaffolding decision for all zBRETT code and project files: which
codebases exist, how the repositories are organized, and how the code reaches a
public **EUPL-1.2** GitHub mirror. The living version of these decisions is the
`docs/adr/` folder inside the `zbrett` repo (ADR-0001…0003); this page is the
consolidated overview for Confluence.

## 1. The decision in one paragraph

All zBRETT software lives in **one `uv`-workspace monorepo, `zbrett`**
(`git@bitbucket.org:precisyn/zbrett.git`), placed as a sibling of `website/`
inside `C:\Dev\dasBRETT`. It contains seven Python packages plus measurement
tooling and deployment assets. Three things stay outside it: the marketing site
(`xbrett-website`, already its own repo), the RNode firmware (external GPLv3
upstream), and the dictionary training corpus (data, not source). Bitbucket is
the private working origin; a public GitHub mirror under EUPL-1.2 is pushed from
CI on `main` and tags.

## 2. Why a monorepo, not one repo per component

The eight Jira epics (E1–E8) decompose into several Python components, but they
**share one wire format and one policy schema — and that contract is still
moving.** `inline_max` is not fixed until M3 (TT-11); the BEACON/INLINE layout
and the policy object are the interface every package depends on. Splitting those
consumers across repositories during the MVP would mean version-pinning a schema
that changes weekly — precisely the "dictionary migration = data-loss event"
failure mode the concept keeps warning about. One atomic commit can change the
wire format and every consumer together. It is also just **one entry in
`repos.psd1`** and one `uv sync`, which fits the existing git-bitbucket tooling.

The one deliberate exception is the **Airtime-Governor** (`brett-governor`): it
has standalone value to the wider Reticulum community and is the planned
candidate to be split into its own repo and upstreamed once stable. It is
therefore already isolated — it depends only on `rns` and `prometheus-client`,
never on `brett-core` — so the future split is a move, not a refactor.

## 3. The codebases

| Package (import) | Epic | Role | Key modules → Jira |
|---|---|---|---|
| `brett-core` (`brett.core`) | E2 | **Shared contract** — DAG store, dag-cbor/CIDv1 codec, policy, dict index | dag TT-16 · codec TT-17 · policy TT-18 · dictionary TT-19 |
| `brett-sync` (`brett.sync`) | E3 | Minisketch set-reconciliation | minisketch TT-20 · protocol TT-21 · TCP harness TT-22 |
| `brett-governor` (`brett.governor`) | E4 | DutyCycleInterface (hub-only) — **split candidate** | interface TT-23 · queue TT-24 · announce TT-25 · metrics TT-26 · airtime TT-27 |
| `brett-fettnetz` (`brett.fettnetz`) | E6 | Wantlist, IPFS/Kubo fetch, gateway/pinning | wantlist TT-31 · ipfs TT-32 · gateway TT-33 |
| `brettd` (`brett.daemon`) | E5 | **The daemon** — wires the layers, endnode/hub roles, LXMF | transport TT-28/29/30 |
| `brett-nntp` (`brett.nntp`) | E7 | Read-only NNTP frontend | server TT-34 |
| `brett-dict` (`brett.dict_train`) | E1/E7 | Dictionary training + M3 bake-off | train TT-37 · bakeoff TT-11 |
| `measurements/` | E1 | M1/M2/M3 protocols + provisioning (not a package) | TT-9/10/11, TT-38…42 |
| `deploy/` | E8 | systemd, gateway compose (Kubo), Prometheus | — |

Brand/repo name is **zBRETT**; the Python import namespace is **`brett`** (a PEP
420 implicit namespace, so each package contributes `brett.<sub>`), and the
daemon console entry point is **`brettd`** — matching the naming already used
throughout the MVP spec.

## 4. What stays out of the monorepo, and why

**`xbrett-website`** — already a separate Bitbucket repo with a different
lifecycle (Netlify, static, bilingual) and audience. No reason to fold it in.

**RNode firmware** — external upstream (`markqvist/RNode_Firmware`), **GPLv3**.
The host talks to the board over USB-serial (KISS); nothing is linked. If a board
port is ever needed (T-Deck, ThinkNode M1), that is a *fork of an external repo*
and lives on its own, staying GPLv3. Keeping it separate is also what keeps the
GPL boundary clean (see §6).

**Dictionary corpus** — the 10k-post German training corpus is data, not source.
It is gitignored (`packages/brett-dict/corpus/`). Trained dictionaries are small
and published to IPFS by CID, exactly like every other content object.

## 5. Repository placement and workflow

```
C:\Dev\dasBRETT\
├─ zbrett\          ← NEW: the code monorepo (this scaffold)
├─ website\         ← existing xbrett-website repo
├─ docs\            ← Confluence-source markdown + diagrams
└─ _stage*\         ← website staging snapshots
```

The scaffold ships with your git-bitbucket dev-scripts (`dev-sync`, `dev-ship`,
`dev-doctor`, `precheck`, …) already copied in, `config/git.local.psd1` pointed at
the new remote, and a `scripts/repos.psd1` registry so `repos.ps1` refreshes
`zbrett` and `xbrett-website` together. Workflow is solo/trunk on `main`, same as
the website.

## 6. Licensing: EUPL-1.2 and the GitHub mirror

The stack is **EUPL-1.2** and **REUSE-compliant**: `LICENSES/EUPL-1.2.txt`
(official text), `REUSE.toml`, and an SPDX header in every source file.
`reuse lint` passes and gates CI.

**Dependency compatibility** — every upstream is permissive and safe to combine
under EUPL-1.2: Reticulum/RNS and LXMF (MIT), libminisketch (MIT), Kubo/IPFS
(MIT+Apache, separate process), zstandard/brotli (BSD/MIT), cbor2/httpx/
prometheus-client (MIT/BSD/Apache). The **RNode firmware's GPLv3 does not reach
the Python stack** because it is a separate program communicating over KISS — no
linking, no copyleft propagation. EUPL-1.2's §5 compatibility list (GPLv2/v3,
AGPLv3, …) is the escape hatch only if a copyleft component ever has to be
*linked*; permissive dependencies never trigger it.

**Mirror mechanism** — develop on Bitbucket (private origin); CI mirrors `main`
and tags one-way to a public GitHub repo via `tools/mirror-to-github.sh`
(`bitbucket-pipelines.yml`). Issues and PRs stay on Bitbucket/Jira until, and if,
the project becomes community-facing. The public mirror is EUPL-1.2 from the
first pushed commit.

## 7. First-push checklist

1. `cd C:\Dev\dasBRETT\zbrett`
2. Create the empty Bitbucket repo `precisyn/zbrett` (private).
3. `.\scripts\bootstrap-first-push.ps1` — inits, commits, pushes `main`.
4. `uv sync` locally to confirm the workspace resolves; `uv run reuse lint`.
5. When ready to publish: create the public GitHub repo, set the CI variable
   `GITHUB_MIRROR_URL` (tokened HTTPS), and the next `main` build mirrors it.
6. Delete `C:\Dev\dasBRETT\_to_delete\` (the parked scaffold source zip).

## 8. Build order (from MVP §13)

Phase 0 **measure** (M1/M2/M3 — block everything) → 1 **core** → 2 **sync** (over
TCP, before radio) → 3 **governor** (bench, 2 RNodes) → 4 **transport/endnode** →
5 **fettnetz** → 6 **NNTP + field test**. The scaffold is laid out so each phase
fills in stubs that already carry the right Jira reference.
