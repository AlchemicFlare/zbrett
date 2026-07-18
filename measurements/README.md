# measurements (E1 — Messungen, blockiert alles)

These block everything downstream (MVP §14). Not a Python package — scripts,
notebooks and raw results. Large raw captures (`*.pcap`, `*.raw`) are gitignored;
commit the analysis and the conclusions.

| Dir | TT | Question | Decides |
|---|---|---|---|
| `m1_announce_overhead/` | TT-9 | Reticulum self-traffic at SF11, 8 neighbours, 24 h | announce thinning rate; governor-over-LXMF viable if <15 % |
| `m2_timeout_tolerance/` | TT-10 | how long may an interface delay before links break | max queue depth |
| `m3_compression_bakeoff/` | TT-11 | brotli vs zstd vs token-Huffman vs raw | compressor + `inline_max` |
| `provisioning/` | TT-38..42 | host toolchain, RNode flashing (RAK4631, T-Deck) | M1 measurement rig |

> ⚠ **Antenna before power.** Always attach the 868 MHz antenna or a 50 Ω dummy
> load before powering/flashing an SX1262 board — seconds without it destroy the PA.
