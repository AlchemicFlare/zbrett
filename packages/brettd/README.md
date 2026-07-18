# brettd (E5 — Transport-Integration + the app)

The daemon. Wires the data layer, sync and fat-net together and speaks LXMF/RNS.
Two roles from one binary (MVP §10, architecture diagram):

- **Endnode** — LXMF vanilla, no governor (budget never critical) — TT-29
- **Hub** — full brett store, pinning, policy enforcement, and the
  `brett-governor` DutyCycleInterface under RNS — TT-28

| Module | TT | Purpose |
|---|---|---|
| `app.py` | E5 | role wiring, lifecycle |
| `transport.py` | TT-28/29/30 | LXMF binding (hub path + endnode vanilla path), 2-node functest |
| `config.py` | — | role/interface/brett config |
| `__main__.py` | — | `brettd` entry point |

The governor is imported only in the hub role, keeping the endnode dependency-light.
