# brett-fettnetz (E6 — Fettnetz)

The bridge to the internet. A BEACON is a promise; the CID is the contract. When
fat-net (WLAN/LTE) appears, bulk-fetch the wantlist CIDs (MVP §8).

| Module | TT | Purpose |
|---|---|---|
| `wantlist.py` | TT-31 | wantlist + fetch logic, priority + expiry (Risk: 3 months = thousands of CIDs) |
| `ipfs.py` | TT-32 | IPFS fetch via Kubo HTTP API |
| `gateway.py` | TT-33 | gateway role + pinning (hub = pinning service with an airtime budget) |
