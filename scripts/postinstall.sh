#!/bin/sh
set -e

# Create caddy user and group if they don't exist
if ! getent group caddy > /dev/null 2>&1 ; then
    groupadd --system caddy
fi

if ! getent passwd caddy > /dev/null 2>&1 ; then
    useradd --system \
        --gid caddy \
        --create-home \
        --home-dir /var/lib/caddy \
        --shell /usr/sbin/nologin \
        --comment "Caddy web server" \
        caddy
fi

# Set ownership
chown -R caddy:caddy /var/lib/caddy 2>/dev/null || true
chown -R caddy:caddy /etc/caddy 2>/dev/null || true

# Reload systemd
if [ -d /run/systemd/system ]; then
    systemctl daemon-reload >/dev/null 2>&1 || true
    systemctl enable caddy >/dev/null 2>&1 || true
fi

echo "Caddy with custom plugins installed successfully!"
echo "Verify plugins: caddy list-modules | grep -E '(cloudflare|redis|postgres|brotli)'"
