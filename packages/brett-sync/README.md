# brett-sync (E3 — Sync / Minisketch)

Set-reconciliation over IBLT/Minisketch (Bitcoin Erlay), not push-with-watermark:
LoRa has neither order nor reliability (MVP §7).

| Module | TT | Purpose |
|---|---|---|
| `minisketch.py` | TT-20 | ctypes binding to libminisketch (~200 lines, doesn't exist upstream) |
| `protocol.py` | TT-21 | SYNC_REQ / SYNC_RESP, recursive time-window halving |
| `harness.py` | TT-22 | TCP test harness — **debug sync over TCP before radio** (Phase 2) |

A 128 B sketch reconciles ~8 entries regardless of brett size.
