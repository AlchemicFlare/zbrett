# zBRETT — code monorepo

[![status: pre-alpha](https://img.shields.io/badge/status-pre--alpha-orange)]()
[![license: EUPL-1.2](https://img.shields.io/badge/license-EUPL--1.2-blue)](LICENSES/EUPL-1.2.txt)
[![chat: Matrix](https://img.shields.io/badge/chat-Matrix-brightgreen)](https://matrix.to/#/!DvdDawmoYjcuPhFTlf:matrix.org?via=matrix.org)

> **Beacon-Relayed Emergency-capable Threaded Transport**
> Threaded, asynchronous forum discussion over LoRa radio.
> Maus/ZConnect semantics · IPFS data model · Reticulum transport.

> [!NOTE]
> **Status: early stage — pre-implementation.** The architecture and specs are
> settled; the code is scaffolding. Every package is a typed stub that raises
> `NotImplementedError`, waiting for its first real commit. This is the ground
> floor — **co-developers wanted**, see [Get involved](#get-involved--co-developers-wanted).

This repository is the **single source of truth for the zBRETT software stack**.
It is a `uv` workspace of Python packages that share one still-moving wire format
and policy schema, plus measurement tooling and deployment assets.

Project management lives in Jira: **TT** — https://precisyn.atlassian.net/jira/software/projects/TT
Concept & specs live in Confluence (Space **P**). The marketing site is a
separate repo (`xbrett-website`).

## Get involved — co-developers wanted

zBRETT is at the ground floor and looking for **co-developers**. If threaded
forums over LoRa — Reticulum transport, an IPLD/Merkle-DAG data model, minisketch
set-reconciliation, a 1 % duty-cycle airtime governor — sounds like your idea of
fun, come build it.

**Talk to us first.** The project chat is on Matrix:
**https://matrix.to/#/!DvdDawmoYjcuPhFTlf:matrix.org?via=matrix.org** — drop in,
say hi, pick a piece. Or email **hello@protagx.com**.

**How contribution works (for now).** Development happens on a private Bitbucket
origin; this GitHub repo is a read-only **EUPL-1.2 mirror**, so its Issues are off
and it doesn't take pull requests directly. We work **vet-then-invite**: reach out
on Matrix (or by email), tell us what you'd like to own, and we grant commit access
once we've talked. Deliberately small while the wire format is still moving — this
will open up as the project matures. By contributing you agree your work is
licensed under the **EUPL-1.2**.

**Good first areas** — each maps to a Jira epic, mirrored here as a package stub:

| Area | Epic | What it is |
|---|---|---|
| `brett-core` | E2 | the data layer everything imports — DAG store, dag-cbor/CIDv1 codec, policy |
| `brett-sync` | E3 | minisketch ctypes wrapper + the SYNC protocol (debuggable over TCP, no radio needed) |
| `brett-governor` | E4 | the DutyCycleInterface — meatiest piece, and upstreamable to Reticulum |
| `brett-fettnetz` | E6 | IPFS/Kubo fetch + gateway |
| `brett-nntp` | E7 | read-only NNTP frontend — "the moment it feels like Maus" |
| `measurements` | E1 | M1–M3 hardware measurements (RAK4631 / T-Deck, SF11/868) |

The [build order](#build--phase-order-from-mvp-13) below is the natural on-ramp.

## Layout

```
packages/
  brett-core/       E2  DAG store (SQLite), dag-cbor/CIDv1 codec, policy, dict index
  brett-sync/       E3  minisketch ctypes wrapper + SYNC_REQ/RESP protocol
  brett-governor/   E4  DutyCycleInterface (RNS interface, hub-only) — SPLIT CANDIDATE
  brett-fettnetz/   E6  wantlist, IPFS/Kubo fetch, gateway/pinning
  brettd/           E5  the daemon: wires core+sync+fettnetz+transport, endnode/hub roles
  brett-nntp/       E7  read-only NNTP frontend (GROUP/ARTICLE/XOVER)
  brett-dict/       E1/E7 dictionary training + M3 compression bake-off (corpus stays OUT of git)
measurements/       E1  M1/M2/M3 protocols, provisioning (TT-38..42), notebooks, results
deploy/             E8  systemd units, gateway compose (Kubo), Prometheus
docs/adr/               architecture decision records
```

## Namespaces

Repo/brand: **zBRETT**. Import namespace: **`brett`** (PEP 420 implicit namespace):
`brett.core`, `brett.sync`, `brett.governor`, `brett.fettnetz`, `brett.daemon`,
`brett.nntp`, `brett.dict_train`. The daemon console entry point is `brettd`.

## Getting started

```bash
# requires uv (https://docs.astral.sh/uv/)
uv sync --all-packages       # resolve + install every workspace package (editable)
uv run pytest                # run all package tests
uv run ruff check .          # lint
uv run reuse lint            # verify EUPL-1.2 licensing compliance
uv run brettd --help         # the daemon (once implemented)
```

## Licensing

Licensed under the **EUPL-1.2**. This Bitbucket repo is the working origin;
a public **GitHub mirror** (also EUPL-1.2) is pushed from CI on `main` and tags.
See `docs/adr/0002-eupl-1.2-github-mirror.md` and `LICENSES/`.

## Build / phase order (from MVP §13)

Phase 0 measure (M1/M2/M3) → 1 core → 2 sync → 3 governor → 4 transport/endnode
→ 5 fettnetz → 6 nntp + field test. **Sync is debugged over TCP before radio.**
