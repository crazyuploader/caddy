#!/bin/sh
set -e

# Usage: ./generate_metadata.sh [VERSION]
# If VERSION is not provided, tries to get it from git tag or uses "custom"

CADDY_VERSION="$1"
if [ -z "$CADDY_VERSION" ]; then
	CADDY_VERSION=$(git describe --tags --exact-match 2>/dev/null || echo "custom-dev")
fi

# Determine Go version
GO_VERSION=$(go version | awk '{print $3}') || "unknown"

# Build Date
BUILD_DATE=$(date +"%b %d, %Y")

# Create the JSON content
# We use a heredoc for the template, injecting variables.
# The plugins and examples are hardcoded to match the custom build definition.

cat >public/build-metadata.json <<EOF
{
  "caddy_version": "${CADDY_VERSION}",
  "go_version": "${GO_VERSION}",
  "build_date": "${BUILD_DATE}",
  "plugins": [
    {
      "name": "Cloudflare DNS",
      "icon": "☁️",
      "description": "ACME DNS-01 challenge provider for wildcard certificates without exposing ports 80/443. Perfect for internal services and multi-domain setups.",
      "version": "v0.9.0",
      "repo_url": "https://github.com/caddy-dns/cloudflare",
      "docs_url": "https://caddyserver.com/docs/modules/dns.providers.cloudflare"
    },
    {
      "name": "Caddy Security",
      "icon": "🔐",
      "description": "Authentication, Authorization, and Accounting (AAA) app and plugin. Implements Form-Based, Basic, Local, LDAP, OpenID Connect, OAuth 2.0, SAML Authentication. MFA/2FA with App Authenticators and Yubico. Authorization with JWT/PASETO tokens.",
      "version": "v1.1.52",
      "repo_url": "https://github.com/greenpau/caddy-security",
      "docs_url": "https://docs.authcrunch.com"
    },
    {
      "name": "Redis Storage",
      "icon": "🔴",
      "description": "Store certificates and cluster state in Redis for true multi-instance deployments. Essential for Kubernetes and high-availability setups.",
      "version": "v0.3.2",
      "repo_url": "https://github.com/pberkel/caddy-storage-redis",
      "docs_url": "https://github.com/pberkel/caddy-storage-redis#readme"
    },
    {
      "name": "PostgreSQL Storage",
      "icon": "🐘",
      "description": "PostgreSQL-backed certificate storage for centralized management and compliance requirements. Integrates with existing database infrastructure.",
      "version": "v2.3.2",
      "repo_url": "https://github.com/yroc92/postgres-storage",
      "docs_url": "https://github.com/yroc92/postgres-storage#readme"
    },
    {
      "name": "Cloudflare KV",
      "icon": "🌐",
      "description": "Leverage Cloudflare Workers KV for globally distributed edge certificate storage with ultra-low latency access.",
      "version": "v0.1.1",
      "repo_url": "https://github.com/mentimeter/caddy-storage-cf-kv",
      "docs_url": "https://github.com/mentimeter/caddy-storage-cf-kv#readme"
    },
    {
      "name": "Brotli Compression",
      "icon": "📦",
      "description": "Modern Brotli compression providing 15-25% better compression than gzip for faster page loads and reduced bandwidth costs.",
      "version": "v0.2.8",
      "repo_url": "https://github.com/ueffel/caddy-brotli",
      "docs_url": "https://github.com/ueffel/caddy-brotli#readme"
    },
    {
      "name": "Rate Limit",
      "icon": "🚦",
      "description": "Enable rate limiting for HTTP requests to prevent abuse and manage traffic spikes.",
      "version": "v0.1.0",
      "repo_url": "https://github.com/mholt/caddy-ratelimit",
      "docs_url": "https://github.com/mholt/caddy-ratelimit#readme"
    },
    {
      "name": "Layer 4",
      "icon": "🛡️",
      "description": "Layer 4 (TCP/UDP) matching and proxying.",
      "version": "v0.0.0-20260127203130-040d25cc886a",
      "repo_url": "https://github.com/mholt/caddy-l4",
      "docs_url": "https://github.com/mholt/caddy-l4#readme"
    },
    {
      "name": "Caddy WAF",
      "icon": "🔒",
      "description": "Web Application Firewall providing OWASP CRS rules, IP blocking, rate limiting, and request inspection to protect against common web attacks.",
      "version": "v0.3.3",
      "repo_url": "https://github.com/fabriziosalmi/caddy-waf",
      "docs_url": "https://github.com/fabriziosalmi/caddy-waf#readme"
    }
  ],
  "examples": [
    {
      "name": "Cloudflare DNS",
      "title": "Caddyfile - Wildcard Certificate",
      "code": "# Get wildcard certificate for all subdomains\n*.example.com {\n    tls {\n        dns cloudflare {env.CLOUDFLARE_API_TOKEN}\n    }\n    \n    # Your site configuration\n    reverse_proxy localhost:3000\n}",
      "note": "Set your API token as environment variable: export CLOUDFLARE_API_TOKEN=your_token_here"
    },
    {
      "name": "Caddy Security",
      "title": "Caddyfile - Form-Based Authentication",
      "code": "example.com {\n    # Enable authentication portal\n    auth_portal {\n        /portal internal\n        /portal/signout\n    }\n\n    # Protect admin area\n    @admin {\n        path /admin/*\n    }\n\n    reverse_proxy @admin localhost:8080\n}",
      "note": "Users can self-register via /portal/register. Configure providers like Google, GitHub, etc. via the security app."
    },
    {
      "name": "Redis Storage",
      "title": "Caddyfile - Redis Certificate Storage",
      "code": "{\n    # Store certificates in Redis for cluster deployments\n    storage redis {\n        host localhost:6379\n        password {env.REDIS_PASSWORD}\n        db 0\n        key_prefix \"caddy\"\n    }\n}\n\nexample.com {\n    reverse_proxy localhost:8080\n}",
      "note": "Ensure Redis is running and accessible. Use environment variables for sensitive data."
    },
    {
      "name": "Brotli Compression",
      "title": "Caddyfile - Enable Brotli Compression",
      "code": "example.com {\n    # Enable both Brotli and Gzip compression\n    encode {\n        brotli 6  # Compression level (0-11)\n        gzip 6    # Fallback for older browsers\n    }\n    \n    file_server\n    root * /var/www/html\n}",
      "note": "Brotli level 6 provides a good balance between compression ratio and speed."
    },
    {
      "name": "PostgreSQL Storage",
      "title": "Caddyfile - PostgreSQL Storage",
      "code": "{\n    # Use PostgreSQL for certificate storage\n    storage postgres {\n        host localhost\n        port 5432\n        database caddy\n        user caddy\n        password {env.POSTGRES_PASSWORD}\n        table_name certificates\n    }\n}\n\nexample.com {\n    reverse_proxy localhost:3000\n}",
      "note": "Create the database and user beforehand. The table will be created automatically."
    }
  ]
}
EOF

echo "Generated public/build-metadata.json"
