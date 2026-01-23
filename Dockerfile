FROM alpine:latest

RUN apk add --no-cache ca-certificates mailcap

COPY caddy /usr/bin/caddy

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
