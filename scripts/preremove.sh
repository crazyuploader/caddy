#!/bin/sh
set -e

# Cross-platform preremove script
# DEB: $1 = "remove" or "upgrade"
# RPM: $1 = 0 (uninstall) or 1 (upgrade)
# APK: no arguments

# Determine if this is a removal (not upgrade)
is_remove() {
	case "$1" in
	remove | 0 | "")
		return 0
		;;
	*)
		return 1
		;;
	esac
}

if [ -d /run/systemd/system ] && is_remove "$1"; then
	systemctl --no-reload disable caddy >/dev/null 2>&1 || true
	systemctl stop caddy >/dev/null 2>&1 || true
	systemctl --no-reload disable caddy-api >/dev/null 2>&1 || true
	systemctl stop caddy-api >/dev/null 2>&1 || true
fi
