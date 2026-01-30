# Caddy Web Server

[![Release Custom Caddy](https://github.com/crazyuploader/caddy/actions/workflows/release.yml/badge.svg)](https://github.com/crazyuploader/caddy/actions/workflows/release.yml)
[![CI](https://github.com/crazyuploader/caddy/actions/workflows/ci.yml/badge.svg)](https://github.com/crazyuploader/caddy/actions/workflows/ci.yml)

Custom [Caddy Web Server](https://github.com/caddyserver/caddy) build with additional plugins, available as `.deb`, `.rpm`, `.apk` packages and pre-built binaries.

## Included Plugins

| Plugin                                                             | Description                                      |
| ------------------------------------------------------------------ | ------------------------------------------------ |
| [cloudflare-dns](https://github.com/caddy-dns/cloudflare)          | DNS provider for Cloudflare (ACME DNS challenge) |
| [redis-storage](https://github.com/pberkel/caddy-storage-redis)    | Redis storage for certificates                   |
| [postgres-storage](https://github.com/yroc92/postgres-storage)     | PostgreSQL storage for certificates              |
| [cf-kv-storage](https://github.com/mentimeter/caddy-storage-cf-kv) | Cloudflare KV storage                            |
| [brotli](https://github.com/ueffel/caddy-brotli)                   | Brotli compression encoder                       |
| [rate-limit](https://github.com/mholt/caddy-ratelimit)             | HTTP rate limiting                               |
| [layer4](https://github.com/mholt/caddy-l4)                        | Layer 4 (TCP/UDP) matching and proxying          |

## Installation

### Via APT (Recommended)

```bash
# Add GPG key
curl -fsSL https://caddy.devjugal.com/public.key | sudo gpg --dearmor -o /usr/share/keyrings/caddy-custom.gpg

# Add repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/caddy-custom.gpg] https://caddy.devjugal.com stable main" | sudo tee /etc/apt/sources.list.d/caddy-custom.list

# Install
sudo apt update
sudo apt install caddy
```

### Migrate from Official Caddy (One-liner)

If you have the official Caddy package installed, this one-liner will backup configs, disable the official repo, and install the custom build:

```bash
curl -fsSL https://caddy.devjugal.com/migrate.sh | sudo bash
```

<details>
<summary>Or run manually</summary>

```bash
# Backup existing configs
sudo cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.official.bak 2>/dev/null || true
sudo cp /lib/systemd/system/caddy.service /lib/systemd/system/caddy.service.official.bak 2>/dev/null || true

# Disable official Caddy repo
sudo mv /etc/apt/sources.list.d/caddy-stable.list /etc/apt/sources.list.d/caddy-stable.list.disabled 2>/dev/null || true

# Stop Caddy
sudo systemctl stop caddy 2>/dev/null || true

# Add custom repo and install
curl -fsSL https://caddy.devjugal.com/public.key | sudo gpg --dearmor -o /usr/share/keyrings/caddy-custom.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/caddy-custom.gpg] https://caddy.devjugal.com stable main" | sudo tee /etc/apt/sources.list.d/caddy-custom.list
sudo apt update
sudo apt install caddy
```

</details>

### RPM (Fedora/RHEL/CentOS)

Download the latest `.rpm` from [GitHub Releases](https://github.com/crazyuploader/caddy/releases):

```bash
# Install directly from URL (replace version as needed)
sudo rpm -i https://github.com/crazyuploader/caddy/releases/latest/download/caddy_VERSION_linux_amd64.rpm

# Or download first
wget https://github.com/crazyuploader/caddy/releases/latest/download/caddy_VERSION_linux_amd64.rpm
sudo rpm -i caddy_VERSION_linux_amd64.rpm
```

### Alpine Linux

Download the latest `.apk` from [GitHub Releases](https://github.com/crazyuploader/caddy/releases):

```bash
# Download and install (replace version as needed)
wget https://github.com/crazyuploader/caddy/releases/latest/download/caddy_VERSION_linux_amd64.apk
sudo apk add --allow-untrusted caddy_VERSION_linux_amd64.apk
```

### Binary (Any Linux/macOS/Windows)

Download pre-built binaries from [GitHub Releases](https://github.com/crazyuploader/caddy/releases):

| Platform | Architecture  | File                                 |
| -------- | ------------- | ------------------------------------ |
| Linux    | amd64         | `caddy_VERSION_linux_amd64.tar.gz`   |
| Linux    | arm64         | `caddy_VERSION_linux_arm64.tar.gz`   |
| Linux    | armv7         | `caddy_VERSION_linux_armv7.tar.gz`   |
| macOS    | amd64         | `caddy_VERSION_darwin_amd64.tar.gz`  |
| macOS    | arm64 (M1/M2) | `caddy_VERSION_darwin_arm64.tar.gz`  |
| Windows  | amd64         | `caddy_VERSION_windows_amd64.zip`    |
| FreeBSD  | amd64         | `caddy_VERSION_freebsd_amd64.tar.gz` |

## Usage

After installation, Caddy runs as a systemd service:

```bash
# Start Caddy
sudo systemctl start caddy

# Enable on boot
sudo systemctl enable caddy

# Check status
sudo systemctl status caddy

# Reload configuration
sudo systemctl reload caddy
```

### Configuration

Edit the Caddyfile at `/etc/caddy/Caddyfile`:

```bash
sudo nano /etc/caddy/Caddyfile
```

### Verify Plugins

```bash
caddy list-modules | grep -E '(dns.providers.cloudflare|caddy.storage.redis|caddy.storage.postgres|caddy.storage.cloudflare_kv|http.encoders.br|http.handlers.rate_limit|layer4)'
```

## License

[MIT](LICENSE)
