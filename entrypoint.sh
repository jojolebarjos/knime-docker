#!/usr/bin/env bash

set -euxo pipefail

xpra seamless --daemon=no --no-audio &

sleep 0.5

exec caddy run --config /etc/caddy/Caddyfile
