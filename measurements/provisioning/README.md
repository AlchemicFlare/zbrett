# Provisioning (TT-38 … TT-42)

Host toolchain + RNode flashing for the M1 rig. Two-step flash rule — the common
mistake is forgetting step 2 (provisioning):

1. `rnodeconf --autoinstall`   (base firmware; web-flasher is the fallback)
2. provision in the same flow  (EEPROM config + firmware hash)

Verify: `rnodeconf --info /dev/ttyACM0` → board, firmware, **SX1262**, 868 MHz.

- TT-38 host toolchain + Reticulum/rnodeconf
- TT-39 RAK4631 as RNode (868)
- TT-40 T-Deck Plus as RNode (ESP32-S3 + SX1262, 868) — **verify chip is SX1262, not SX1276**
- TT-41 measurement rig: rnsd, packet logging, 8-neighbour scenario (SF11/868)
- TT-42 analysis, E4 scope decision, backfill chapter 14
