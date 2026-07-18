# brett-governor (E4 — Airtime-Governor) — ⚠ SPLIT CANDIDATE

The **DutyCycleInterface**: an RNS `Interface` that sits *under* Reticulum, where
airtime physically arises, and does rolling-window airtime accounting for a 1 %
duty cycle. It **delays, never drops** — a dropped beacon is lost, a delayed one
arrives (MVP §10). This is the biggest single item and the likeliest source of
field surprises (Risk §16).

> **Why isolated / minimal deps:** this component has standalone value to the
> wider Reticulum community and is the planned candidate to be **split into its
> own repo and upstreamed** once stable (see ADR-0001). Keep it depending only
> on `rns` + `prometheus-client` — never on `brett-core`.

| Module | TT | Purpose |
|---|---|---|
| `interface.py` | TT-23 | DutyCycleInterface skeleton (RNS Interface subclass) |
| `queue.py` | TT-24 | priority queue: BEACON > SYNC > announce > proof |
| `announce.py` | TT-25 | announce thinning (a static hub needs no 360 s) |
| `metrics.py` | TT-26 | Prometheus export — else blind in the field |
| `airtime.py` | TT-27 | time-on-air (ToA) calculator from SF/BW/payload |
