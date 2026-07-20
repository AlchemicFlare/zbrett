#!/bin/sh
# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
#
# Seed a default Reticulum config on first run (so the identity/storage persist
# in the /config volume), then run the daemon.
set -e
if [ ! -f /config/config ]; then
  cp /opt/reticulum-default/config /config/config
  echo "[entrypoint] seeded default Reticulum config into /config"
fi
exec rnsd --config /config -v
