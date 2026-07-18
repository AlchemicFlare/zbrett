# deploy (ops)

Deployment assets for hubs and the gateway. A hub = board + SBC (a host runs
`rnsd`, `brettd`, the DutyCycleInterface, the Prometheus exporter). Solar hubs
run a Raspberry Pi, never an x86 mini-PC (power budget — Hardware §4a).

- `systemd/` — units for `rnsd` and `brettd`
- `compose/` — gateway stack (Kubo/IPFS) for the fat-net bridge
- `prometheus/` — scrape config for the governor metrics
