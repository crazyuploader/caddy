#!/bin/sh
set -e

# Cross-platform preinstall script
# Handles migration from official Caddy package (Debian/Ubuntu only)

# Only run migration logic on Debian-based systems with dpkg
if command -v dpkg >/dev/null 2>&1; then
	# Check if official Caddy repository is configured
	OFFICIAL_CADDY_LIST="/etc/apt/sources.list.d/caddy-stable.list"

	# Backup existing configuration if official Caddy is installed
	if dpkg -l caddy 2>/dev/null | grep -q "^ii"; then
		echo "Detected existing Caddy installation..."

		# Check if it's the official package (has different maintainer)
		INSTALLED_MAINTAINER=$(dpkg -s caddy 2>/dev/null | grep "^Maintainer:" | cut -d: -f2- | xargs)

		if [ -n "$INSTALLED_MAINTAINER" ] && echo "$INSTALLED_MAINTAINER" | grep -qv "Jugal Kishore"; then
			echo "Official Caddy package detected. Preparing migration..."

			# Backup Caddyfile if it exists
			if [ -f /etc/caddy/Caddyfile ]; then
				cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.official.bak
				echo "Backed up Caddyfile to /etc/caddy/Caddyfile.official.bak"
			fi

			# Disable official Caddy APT source if present
			if [ -f "$OFFICIAL_CADDY_LIST" ]; then
				mv "$OFFICIAL_CADDY_LIST" "${OFFICIAL_CADDY_LIST}.disabled"
				echo "Disabled official Caddy APT source (renamed to .disabled)"
			fi

			# Backup systemd service files
			if [ -f /lib/systemd/system/caddy.service ]; then
				cp /lib/systemd/system/caddy.service /lib/systemd/system/caddy.service.official.bak
				echo "Backed up caddy.service to caddy.service.official.bak"
			fi
			if [ -f /lib/systemd/system/caddy-api.service ]; then
				cp /lib/systemd/system/caddy-api.service /lib/systemd/system/caddy-api.service.official.bak
				echo "Backed up caddy-api.service to caddy-api.service.official.bak"
			fi

			echo "Migration preparation complete. Installing custom Caddy build..."
		fi
	fi
fi

# For RPM/APK: Stop service before upgrade if running
if [ -d /run/systemd/system ]; then
	systemctl stop caddy >/dev/null 2>&1 || true
fi
