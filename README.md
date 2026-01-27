# Custom Caddy APT Repository

## Quick Install

```bash
curl -fsSL https://caddy.devjugal.com/public.key | sudo gpg --dearmor -o /usr/share/keyrings/caddy-custom.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/caddy-custom.gpg] https://caddy.devjugal.com stable main" | sudo tee /etc/apt/sources.list.d/caddy-custom.list
sudo apt update && sudo apt install caddy
```

## Migrate from Official Caddy

```bash
curl -fsSL https://caddy.devjugal.com/migrate.sh | sudo bash
```

## Included Plugins

- dns.providers.cloudflare
- caddy.storage.redis
- caddy.storage.postgres
- caddy.storage.cloudflare_kv
- http.encoders.br
- http.handlers.rate_limit

[View Documentation](https://caddy.devjugal.com)
