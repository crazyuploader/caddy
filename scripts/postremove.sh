#!/bin/sh
set -e

# Cross-platform postremove script
# DEB: $1 = "purge", "remove", or "upgrade"
# RPM: $1 = 0 (uninstall) or 1 (upgrade)
# APK: no arguments

# Determine if this is a complete removal (purge)
is_purge() {
	case "$1" in
	purge | 0 | "")
		return 0
		;;
	*)
		return 1
		;;
	esac
}

if is_purge "$1"; then
	# Remove user and group
	if getent passwd caddy >/dev/null 2>&1; then
		userdel caddy 2>/dev/null || true
	fi

	if getent group caddy >/dev/null 2>&1; then
		groupdel caddy 2>/dev/null || true
	fi

	# Remove data directories on purge
	rm -rf /var/lib/caddy 2>/dev/null || true
	rm -rf /etc/caddy 2>/dev/null || true

	# Remove APT pinning preference
	rm -f /etc/apt/preferences.d/caddy-custom 2>/dev/null || true
fi

if [ -d /run/systemd/system ]; then
	systemctl daemon-reload >/dev/null 2>&1 || true
fi
