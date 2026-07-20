# zBRETT dev gateway (host27)

An always-on **Reticulum TCP transport node** (`rnsd`) plus a **Kubo IPFS** node —
the development "fat-net" backbone. This lets the sync (Phase 2) and LXMF
transport (Phase 4) be built and tested **over TCP, before any LoRa hardware**
exists, and gives the fettnetz layer (E6) a real IPFS endpoint to target.

> Supersedes the earlier `deploy/compose/gateway.compose.yml` (IPFS-only) — this
> is the canonical dev-gateway stack.

## What runs

| Service | Port | Purpose | Exposure |
|---|---|---|---|
| `reticulum` (rnsd) | `4965/tcp` | RNS TCPServerInterface — dev machines/endnodes dial in | public (RNS is encrypted) |
| `ipfs` (Kubo) | `4001/tcp+udp` | libp2p swarm | public (how IPFS peers reach it) |
| `ipfs` (Kubo) | `5001/tcp` | HTTP API | **loopback only** — never expose |
| `ipfs` (Kubo) | `8080/tcp` | read-only gateway (optional) | behind Traefik + auth only |

## Deploy on host27 via Portainer

The `reticulum` service builds a small image, so use a **git-based stack** (build
context comes from the repo):

1. Portainer → **Stacks → Add stack → Repository**.
2. Repository URL: your Bitbucket `zbrett` (or the GitHub mirror); reference `main`.
3. **Compose path:** `deploy/gateway/docker-compose.yml`.
4. Deploy. First boot builds the rnsd image and seeds a Reticulum identity into
   the `reticulum_config` volume (persists across restarts).

**SSD for IPFS:** point the `ipfs_data` volume at an SSD-backed path on host27
(IPFS write load kills SD cards / is rough on HDDs). In Portainer, either map the
named volume to an SSD device or replace it with a bind mount to an SSD path.

**Firewall (ufw):**
```bash
sudo ufw allow 4965/tcp   # Reticulum transport
sudo ufw allow 4001       # IPFS swarm (tcp+udp)
# do NOT open 5001 (API) or 8080 (gateway) to the internet
```

## Point a dev machine at the gateway

Add this interface to your local `~/.reticulum/config` and run `rnsd` (or any
Reticulum app) — you're now on the same RNS network as host27, over the internet:

```ini
[[zBRETT gateway]]
  type = TCPClientInterface
  enabled = yes
  target_host = host27.<your-domain>
  target_port = 4965
```

Verify with `rnstatus` — the gateway interface should show as up, and `rnpath`
can resolve destinations announced across it.

## Reach the IPFS API

- From a container on the same host/stack: `http://ipfs:5001` (compose network).
- From your laptop: SSH-tunnel it, never publish 5001:
  ```bash
  ssh -N -L 5001:127.0.0.1:5001 host27
  # then: curl -X POST http://127.0.0.1:5001/api/v0/id
  ```

## Optional: IPFS gateway behind Traefik

To serve read-only content over `ipfs.zbrett.de`, uncomment the `8080` line and
add Traefik labels for your landscape's entrypoint + a middleware (basic-auth or
IP allowlist). Keep it read-only; never route `5001` through Traefik without auth.

## Notes

- `IPFS_PROFILE=server` disables local-network peer discovery (correct for a VPS).
- The Reticulum node is a **transport node** (`enable_transport = True`) so it
  routes for others — that's what makes it a usable backbone.
- Later (Phase 4) add an `RNodeInterface` to `reticulum/config` to bridge onto
  the LoRa side; the TCP interface and the radio interface coexist on one node.
