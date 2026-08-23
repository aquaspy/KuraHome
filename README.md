# KuraHome

A quiet homepage as a Rails 8 PWA. One SQLite file, no Redis.

Add the sites you actually open. Split them into profiles (personal, work, college). Several people can have accounts on the same server.

**Stack** is a table of what you actually use — category, choice, origin, a note, optional link. Share image downloads a PNG card of that profile’s stack.

Tiles and stack rows pick a favicon from the site (DuckDuckGo). Leave the icon field blank for that, or paste any image URL. If the fetch fails, the letter mark stays.

This is not a status dashboard. No ping, no widgets, no iframes. Tiles, a stack, a search box, and a lock.

## Local

```bash
bin/setup
bin/dev
```

Open http://127.0.0.1:3000

A `config/master.key` is created by `rails new` and is gitignored. Keep that file. If you cloned this repo and have no key:

```bash
rm -f config/credentials.yml.enc
EDITOR=true bin/rails credentials:edit
```

That writes a new `config/master.key`. Do not commit it.

## VPS (Docker Compose)

On the server, with Docker installed:

```bash
git clone https://github.com/aquaspy/KuraHome.git
cd KuraHome
cp .env.example .env
```

Edit `.env`. At minimum set:

```bash
SECRET_KEY_BASE=$(openssl rand -hex 64)   # paste the output into .env
KURA_HOST=home.example.com
SIGNUP_ENABLED=true                       # first account, then false
FORCE_SSL=false                           # true once Caddy/nginx terminates HTTPS
BIND=127.0.0.1:3000                       # use 127.0.0.1:3002 if Notes/Chat already took 3000
```

Then:

```bash
docker compose up -d --build
```

Create the first account in the browser (http://127.0.0.1:3000), **or** from the shell:

```bash
docker compose exec web bin/rails kura:create EMAIL=you@x.com PASSWORD='at-least-8'
```

Lock signup:

```bash
# in .env
SIGNUP_ENABLED=false
docker compose up -d
```

`docker compose restart` does **not** reload `.env`. Use `up -d`.

### Secret

Pick **one**. You do not need both.

**Compose (recommended on a VPS):**

```bash
openssl rand -hex 64
```

Put the output in `.env` as `SECRET_KEY_BASE`. No `master.key` required.

**Rails credentials** (if you already have a key, or want `rails credentials:edit`):

```bash
rm -f config/credentials.yml.enc
EDITOR=true bin/rails credentials:edit
cat config/master.key
```

Put that value in `.env` as `RAILS_MASTER_KEY`. A random hex will not decrypt the `credentials.yml.enc` that ships in git — generate a new pair as above, or use `SECRET_KEY_BASE` instead.

Losing the key does not lose sites or the stack. It only invalidates session cookies. Generate a new one and users sign in again.

### Users on the server

Same rake tasks as KuraNotes:

```bash
docker compose exec web bin/rails kura:users
docker compose exec web bin/rails kura:create EMAIL=you@x.com PASSWORD='at-least-8'
docker compose exec web bin/rails kura:password EMAIL=you@x.com PASSWORD='new-secret'
```

`kura:password` is the admin reset. There is no email recovery.

### Proxy (Caddy or nginx)

Nothing is bundled. The app listens on `127.0.0.1:3000` and does not bind 80/443. Point your own Caddy or nginx at that address, set `FORCE_SSL=true` in `.env`, then `docker compose up -d`.

Caddy:

```
home.example.com {
  reverse_proxy 127.0.0.1:3000
}
```

nginx:

```
location / {
  proxy_pass http://127.0.0.1:3000;
  proxy_http_version 1.1;
  proxy_set_header Host $host;
  proxy_set_header X-Forwarded-Proto $scheme;
}
```

If `BIND` is `127.0.0.1:3002`, proxy to that port instead.

### Backup

Sites and the stack live in the `kura_home_data` volume (`storage/production.sqlite3`). Back that up.

```bash
docker compose exec web tar -C /rails/storage -cf - . > kurahome-backup.tar
```

Offline, the PWA can reopen the home page and any profile you already opened while online. Adding or editing a site waits until you are back. Sign out wipes the cache so a second person on the same browser cannot read the previous user’s home offline.

Shared browsers: Sign out **and** wait for the cache wipe.

The search box talks to DuckDuckGo, Startpage, Kagi, Google, or Brave in the browser. Cycle the engine with the pill on the right. That choice stays on the device (`localStorage`), not the server.

## Keys

| Env | What |
| --- | --- |
| `SECRET_KEY_BASE` | Session cookies (Compose). `openssl rand -hex 64` |
| `SIGNUP_ENABLED` | Public signup form. Turn off after the first account |
| `FORCE_SSL` | `true` when Caddy/nginx terminates HTTPS |
| `KURA_HOST` | Public hostname |
| `BIND` | Default `127.0.0.1:3000` |
