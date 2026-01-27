#!/bin/sh
set -e

# Cross-platform postinstall script
# Works on Debian, RPM, and Alpine systems

# Create caddy group if it doesn't exist
if ! getent group caddy >/dev/null 2>&1; then
	if command -v groupadd >/dev/null 2>&1; then
		groupadd --system caddy
	elif command -v addgroup >/dev/null 2>&1; then
		# Alpine uses addgroup
		addgroup -S caddy
	fi
fi

# Create caddy user if it doesn't exist
if ! getent passwd caddy >/dev/null 2>&1; then
	# Create home directory first to avoid warning
	mkdir -p /var/lib/caddy

	if command -v useradd >/dev/null 2>&1; then
		useradd --system \
			--gid caddy \
			--no-create-home \
			--home-dir /var/lib/caddy \
			--shell /usr/sbin/nologin \
			--comment "Caddy web server" \
			caddy
	elif command -v adduser >/dev/null 2>&1; then
		# Alpine uses adduser
		adduser -S -D -H -h /var/lib/caddy -s /sbin/nologin -G caddy -g "Caddy web server" caddy
	fi
fi

# Create config directory if it doesn't exist
mkdir -p /etc/caddy

# Create default Caddyfile if it doesn't exist
if [ ! -f /etc/caddy/Caddyfile ]; then
	cat >/etc/caddy/Caddyfile <<'EOF'
# The Caddyfile is an easy way to configure your Caddy web server.
#
# Included plugins:
# - Cloudflare DNS (dns.providers.cloudflare)
# - Redis Storage (caddy.storage.redis)
# - Postgres Storage (caddy.storage.postgres)
# - Cloudflare KV (caddy.storage.cloudflare_kv)
# - Brotli (http.encoders.br)
# - Rate Limit (http.handlers.rate_limit)
#
# Documentation: https://caddyserver.com/docs/caddyfile

{
	# debug
}

# 1. Default site (e.g. IP address or unknown domains)
:80 {
	respond "Hello, custom Caddy!"
}

# 2. Example: Handling multiple subdomains with a wildcard certificate
# *.example.com {
# 	tls {
# 		dns cloudflare {env.CLOUDFLARE_API_TOKEN}
# 	}
#
# 	# Subdomain A: Static File Server
# 	@site host site.example.com
# 	handle @site {
# 		root * /var/www/site
# 		file_server
# 	}
#
# 	# Subdomain B: Reverse Proxy to an App
# 	@app host app.example.com
# 	handle @app {
# 		reverse_proxy localhost:8080
# 	}
#
# 	# Fallback for other subdomains
# 	handle {
# 		respond "Subdomain not found" 404
# 	}
# }
EOF
fi

# Set ownership
chown -R caddy:caddy /var/lib/caddy 2>/dev/null || true
chown -R caddy:caddy /etc/caddy 2>/dev/null || true

# Add APT pinning to prefer custom repo (Debian/Ubuntu only)
if command -v dpkg >/dev/null 2>&1 && [ ! -f /etc/apt/preferences.d/caddy-custom ]; then
	mkdir -p /etc/apt/preferences.d
	cat >/etc/apt/preferences.d/caddy-custom <<'EOF'
Package: caddy
Pin: origin caddy.devjugal.com
Pin-Priority: 1001
EOF
fi

# Reload, enable and start systemd service
if [ -d /run/systemd/system ]; then
	systemctl daemon-reload >/dev/null 2>&1 || true
	systemctl enable caddy >/dev/null 2>&1 || true
	systemctl start caddy >/dev/null 2>&1 || true
fi

# For Alpine with OpenRC
if command -v rc-update >/dev/null 2>&1; then
	rc-update add caddy default 2>/dev/null || true
fi

echo "Caddy with custom plugins [Cloudflare DNS, Redis Storage, PostgreSQL Storage, Cloudflare KV Storage, Brotli, Rate Limit] installed successfully!"
