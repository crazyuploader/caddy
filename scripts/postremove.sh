#!/bin/sh
set -e

if [ "$1" = "purge" ]; then
    # Remove user and group
    if getent passwd caddy > /dev/null 2>&1; then
        userdel caddy 2>/dev/null || true
    fi
    
    if getent group caddy > /dev/null 2>&1; then
        groupdel caddy 2>/dev/null || true
    fi
    
    # Remove data directory on purge
    rm -rf /var/lib/caddy 2>/dev/null || true
    rm -rf /etc/caddy 2>/dev/null || true
fi

if [ -d /run/systemd/system ]; then
    systemctl daemon-reload >/dev/null 2>&1 || true
fi
