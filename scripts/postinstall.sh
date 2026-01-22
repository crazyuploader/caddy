#!/bin/sh
set -e

# Create caddy user and group if they don't exist
if ! getent group caddy > /dev/null 2>&1 ; then
    groupadd --system caddy
fi

if ! getent passwd caddy > /dev/null 2>&1 ; then
    # Create home directory first to avoid warning
    mkdir -p /var/lib/caddy
    useradd --system \
        --gid caddy \
        --no-create-home \
        --home-dir /var/lib/caddy \
        --shell /usr/sbin/nologin \
        --comment "Caddy web server" \
        caddy
fi

# Create default Caddyfile if it doesn't exist
if [ ! -f /etc/caddy/Caddyfile ]; then
    cat > /etc/caddy/Caddyfile << 'EOF'
# The Caddyfile is an easy way to configure your Caddy web server.
#
# https://caddyserver.com/docs/caddyfile
#
# The configuration below serves a welcome page over HTTP on port 80.

:80 {
    respond "Hello from Caddy!"
}
EOF
fi

# Set ownership
chown -R caddy:caddy /var/lib/caddy 2>/dev/null || true
chown -R caddy:caddy /etc/caddy 2>/dev/null || true

# Reload systemd
if [ -d /run/systemd/system ]; then
    systemctl daemon-reload >/dev/null 2>&1 || true
    systemctl enable caddy >/dev/null 2>&1 || true
fi

echo "Caddy with custom plugins [Cloudflare DNS, Redis Storage, PostgreSQL Storage, Cloudflare KV Storage, Brotli] installed successfully!"
