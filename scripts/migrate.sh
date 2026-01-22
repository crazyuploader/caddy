#!/bin/bash
set -e

echo "=== Caddy Migration Script ==="
echo "Migrating from official Caddy to custom build with plugins"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo"
    exit 1
fi

# Backup existing Caddyfile
if [ -f /etc/caddy/Caddyfile ]; then
    cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.official.bak
    echo "✓ Backed up Caddyfile to /etc/caddy/Caddyfile.official.bak"
fi

# Backup systemd service files
if [ -f /lib/systemd/system/caddy.service ]; then
    cp /lib/systemd/system/caddy.service /lib/systemd/system/caddy.service.official.bak
    echo "✓ Backed up caddy.service"
fi
if [ -f /lib/systemd/system/caddy-api.service ]; then
    cp /lib/systemd/system/caddy-api.service /lib/systemd/system/caddy-api.service.official.bak
    echo "✓ Backed up caddy-api.service"
fi

# Disable official Caddy APT source
if [ -f /etc/apt/sources.list.d/caddy-stable.list ]; then
    mv /etc/apt/sources.list.d/caddy-stable.list /etc/apt/sources.list.d/caddy-stable.list.disabled
    echo "✓ Disabled official Caddy APT source"
fi

# Stop Caddy if running
if systemctl is-active --quiet caddy 2>/dev/null; then
    systemctl stop caddy
    echo "✓ Stopped Caddy service"
fi

# Add custom repository
echo ""
echo "Adding custom Caddy repository..."
curl -fsSL https://caddy.devjugal.com/public.key | gpg --dearmor -o /usr/share/keyrings/caddy-custom.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/caddy-custom.gpg] https://caddy.devjugal.com stable main" | tee /etc/apt/sources.list.d/caddy-custom.list > /dev/null

# Pin custom repo to have higher priority than Ubuntu repos
cat > /etc/apt/preferences.d/caddy-custom << 'EOF'
Package: caddy
Pin: origin caddy.devjugal.com
Pin-Priority: 1001
EOF
echo "✓ Added custom repository with high priority"

# Disable Ubuntu Pro ESM caddy if present
if [ -f /etc/apt/sources.list.d/ubuntu-pro-esm-apps.sources ]; then
    echo "✓ Note: Ubuntu Pro ESM detected, custom repo will override"
fi

# Install
echo ""
echo "Installing custom Caddy build..."
apt-get update -qq
apt-get install -y caddy

echo ""
echo "=== Migration Complete ==="
echo "Custom Caddy with plugins installed!"
echo ""
echo "Your original configs are backed up with .official.bak suffix"
echo "Start Caddy: systemctl start caddy"
