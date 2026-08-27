# KuraHome

**The first tab of the day — without the noise.**

KuraHome is a quiet homepage PWA. Add the sites you actually open. Split them into profiles (personal, work, college). Keep a **Stack** of what you use — tools, services, the boring infrastructure of a life online — and share a PNG card of it when you want. Several people can have accounts on the same server. One SQLite file. No Redis.

---

## Philosophy

Start pages and “new tab” products love widgets: weather, stocks, RSS, status lights, iframes nested inside iframes. Useful for about a week. Then they become a second job.

KuraHome refuses that job.

- **Tiles, not dashboards.** Links you chose, grouped how you think. Favicons when they help; a letter mark when they do not.
- **Profiles as contexts.** Switch between “home” and “work” without mixing every bookmark into one anxious grid.
- **Stack as memory.** A table of what you actually run — category, choice, origin, a note, optional link. Not a status board. A portrait of your setup.
- **Search stays in the browser.** DuckDuckGo, Startpage, Kagi, Google, or Brave — cycled with a pill, remembered on the device (`localStorage`), never forced through your VPS.
- **Same Kura calm.** Auth, idle lock, PWA, Compose on localhost. Your machine, your homepage.

It belongs with [KuraNotes](https://github.com/aquaspy/KuraNotes), [KuraChat](https://github.com/aquaspy/KuraChat), [KuraCalendar](https://github.com/aquaspy/KuraCalendar), and [KuraSpend](https://github.com/aquaspy/KuraSpend). Separate app, separate volume — a homepage should not share a database with your notes or your spend.

**This is not a status dashboard.** No ping, no widgets, no iframes. Tiles, a stack, a search box, and a lock.

---

## What you get

- Multi-user accounts; each person owns their profiles and tiles
- Profiles with reorderable site tiles
- Stack rows with optional share-image (PNG card per profile)
- Favicon fetch via DuckDuckGo when the icon field is blank (paste any image URL to override)
- Offline: reopen the home page and profiles you already opened; edits wait for the network
- Sign-out wipes the offline cache

---

## Self-host (Docker Compose)

```bash
git clone https://github.com/aquaspy/KuraHome.git
cd KuraHome
cp .env.example .env
```

Edit `.env`. At minimum:

```bash
SECRET_KEY_BASE=          # paste: openssl rand -hex 64
KURA_HOST=home.example.com
SIGNUP_ENABLED=true       # first account, then false
FORCE_SSL=false           # true once HTTPS terminates in front
BIND=127.0.0.1:3000       # use 3002 if Notes/Chat already took 3000–3001
```

Then:

```bash
docker compose up -d --build
```

Create the first account in the browser (`http://127.0.0.1:3000`), or:

```bash
docker compose exec web bin/rails kura:create EMAIL=you@example.com PASSWORD='at-least-8'
```

Lock signup:

```bash
# in .env
SIGNUP_ENABLED=false
docker compose up -d
```

> **Important:** `docker compose restart` does **not** reload `.env`. Use `docker compose up -d`.

### Secrets

Pick **one**. You do not need both.

| Approach | When | How |
| --- | --- | --- |
| **`SECRET_KEY_BASE`** (recommended) | Compose / VPS | `openssl rand -hex 64` → `.env` |
| **`RAILS_MASTER_KEY`** | Rails credentials | Regenerate with `EDITOR=true bin/rails credentials:edit`, put `config/master.key` in `.env` |

Losing the key does not lose sites or the stack — only session cookies.

### Reverse proxy (Caddy or nginx)

Nothing is bundled. Point your proxy at `BIND`, set `FORCE_SSL=true`, then `docker compose up -d`.

**Caddy:**

```
home.example.com {
  reverse_proxy 127.0.0.1:3000
}
```

**nginx:**

```
location / {
  proxy_pass http://127.0.0.1:3000;
  proxy_http_version 1.1;
  proxy_set_header Host $host;
  proxy_set_header X-Forwarded-Proto $scheme;
}
```

If `BIND` is `127.0.0.1:3002`, proxy to that port instead.

### Users on the server

No email recovery:

```bash
docker compose exec web bin/rails kura:users
docker compose exec web bin/rails kura:create EMAIL=you@example.com PASSWORD='at-least-8'
docker compose exec web bin/rails kura:password EMAIL=you@example.com PASSWORD='new-secret'
```

### Backup

Sites and the stack live in the `kura_home_data` volume (`storage/production.sqlite3`).

```bash
docker compose exec web tar -C /rails/storage -cf - . > kurahome-backup.tar
```

### Shared browsers

Sign out **and** wait for the cache wipe.

---

## Local development

```bash
bin/setup
bin/dev
```

Open http://127.0.0.1:3000

If you cloned without a `master.key`:

```bash
rm -f config/credentials.yml.enc
EDITOR=true bin/rails credentials:edit
```

Do not commit `config/master.key`.

---

## Environment

| Variable | What it does |
| --- | --- |
| `SECRET_KEY_BASE` | Session cookies (Compose). `openssl rand -hex 64` |
| `SIGNUP_ENABLED` | Public signup. Turn off after the first account |
| `FORCE_SSL` | `true` when Caddy/nginx terminates HTTPS |
| `KURA_HOST` | Public hostname |
| `BIND` | Default `127.0.0.1:3000` |

---

## Sister apps

| App | Role |
| --- | --- |
| [KuraNotes](https://github.com/aquaspy/KuraNotes) | Private notes |
| [KuraChat](https://github.com/aquaspy/KuraChat) | Private chat with Grok |
| [KuraCalendar](https://github.com/aquaspy/KuraCalendar) | Personal calendar & birthdays |
| [KuraSpend](https://github.com/aquaspy/KuraSpend) | Subscriptions & daily spend |
