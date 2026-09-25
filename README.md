# KuraHome (Go)

A quiet homepage for the sites you actually open. Go port of the Rails app on `master`: chi + templ + htmx + SQLite, no build step beyond `templ generate` and the Tailwind CLI.

## Run

```sh
cp .env.example .env   # then edit KURA_HOST
go run ./cmd/kurahome serve
```

Or with Docker:

```sh
docker compose up -d --build
```

Environment: `BIND` (default `127.0.0.1:3000`), `DATA_DIR` (default `storage`), `KURA_HOST` (comma-separated, empty only while testing), `SIGNUP_ENABLED` (default true), `FORCE_SSL` (default false).

## Develop

```sh
templ generate
tailwindcss --input web/static/css/input.css --output web/static/css/app.css
go run ./cmd/kurahome serve
```

Subcommands: `serve` (default), `users`, `create` (`EMAIL=`/`PASSWORD=`), `password` (`EMAIL=`/`PASSWORD=`).

## Test

```sh
gofmt -l cmd internal
go vet ./...
go test ./...
```
