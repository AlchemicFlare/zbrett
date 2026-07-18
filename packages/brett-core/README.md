# brett-core (E2 — Datenschicht)

The shared foundation every other package builds on. **This is the wire-format
and policy contract** — changes here ripple through the whole stack.

| Module | TT | Purpose |
|---|---|---|
| `wire.py` | — | BEACON (~108 B) / INLINE (~76 B) field layout, size constants |
| `dag.py` | TT-16 | DAG store over SQLite (single-parent, append-only) |
| `codec.py` | TT-17 | dag-cbor encode/decode + CIDv1 (full 32 B) |
| `policy.py` | TT-18 | signed IPLD policy objects + enforcement (drop, no relay) |
| `dictionary.py` | TT-19 | 4-bit dict index → `dict_allow[]`, append-only slots |

`inline_max` is **derived from M3** (compression bake-off), not hardcoded here.
