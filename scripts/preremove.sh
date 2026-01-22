#!/bin/sh
set -e

if [ -d /run/systemd/system ] && [ "$1" = "remove" ]; then
    systemctl --no-reload disable caddy >/dev/null 2>&1 || true
    systemctl stop caddy >/dev/null 2>&1 || true
    systemctl --no-reload disable caddy-api >/dev/null 2>&1 || true
    systemctl stop caddy-api >/dev/null 2>&1 || true
fi
