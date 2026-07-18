# zBRETT — code monorepo

> **Beacon-Relayed Emergency-capable Threaded Transport**
> Threaded, asynchronous forum discussion over LoRa radio.
> Maus/ZConnect semantics · IPFS data model · Reticulum transport.

This repository is the **single source of truth for the zBRETT software stack**.
It is a `uv` workspace of Python packages that share one still-moving wire format
and policy schema, plus measurement tooling and deployment assets.

Project management lives in Jira: **TT** — https://precisyn.atlassian.net/jira/software/projects/TT
Concept & specs live in Confluence (Space **P**). The marketing site is a
separate repo (`xbrett-website`).

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
uv sync                      # resolve + install the whole workspace (editable)
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
