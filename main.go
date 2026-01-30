// Custom Caddy build with additional plugins.
// See README.md for the full list of included plugins.
package main

import (
	_ "time/tzdata"

	caddycmd "github.com/caddyserver/caddy/v2/cmd"

	// Standard Caddy modules
	_ "github.com/caddyserver/caddy/v2/modules/standard"

	// Custom plugins
	_ "github.com/caddy-dns/cloudflare"
	_ "github.com/mentimeter/caddy-storage-cf-kv"
	_ "github.com/mholt/caddy-l4"
	_ "github.com/mholt/caddy-ratelimit"
	_ "github.com/pberkel/caddy-storage-redis"
	_ "github.com/ueffel/caddy-brotli"
	_ "github.com/yroc92/postgres-storage"
)

func main() {
	caddycmd.Main()
}
