# brett-dict (E1/E7 — Dictionary & Kompression)

At 140 chars the dictionary *is* the entire compression (LZ77 finds nothing in
140 bytes). A dictionary is a **domain** object (language corpus + brett
vocabulary + structure markers), content-addressed, fetched by CID like anything
else (MVP §6).

| Module | TT | Purpose |
|---|---|---|
| `train.py` | TT-37 | train `de-forum-v1` (zstd --train), corpus from Usenet/Fido de.* dumps |
| `bakeoff.py` | TT-11 | **M3**: brotli vs zstd --train vs token-Huffman vs raw; metric = 5th-percentile rate |

## ⚠ The corpus never enters git
The training corpus (10k German forum posts) lives in `corpus/` which is
**gitignored**. Trained dictionary artifacts are small and published to IPFS by
CID — they are data, not source. Keep the repo lean.
