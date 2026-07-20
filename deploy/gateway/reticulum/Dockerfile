# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
#
# Minimal always-on Reticulum transport node (rnsd) for the zBRETT dev gateway.
FROM python:3.12-slim

# rnsd from the Reticulum package. Pin a known-good line for reproducibility.
RUN pip install --no-cache-dir "rns>=0.7,<0.10" \
    && useradd -m -u 10001 rns \
    && mkdir -p /config /opt/reticulum-default \
    && chown -R rns:rns /config /opt/reticulum-default

COPY config /opt/reticulum-default/config
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER rns
VOLUME ["/config"]
EXPOSE 4965/tcp
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
