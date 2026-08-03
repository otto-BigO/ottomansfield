# ottomansfield.com

my personal corner of the web. a calm, dark, hand-coded static homepage. no
framework, no build step, no npm. just html and css you can open in a browser.

## what's here

```
ottomansfield/
├── index.html       the home page
├── css/style.css    all styling + design tokens (one file)
├── img/             favicon (and anything added later)
├── pages/           future pages go here (about, music, projects)
├── CNAME            contains: ottomansfield.com (for github pages)
├── robots.txt
└── README.md        this file
```

## run it locally

it's just static files. either double-click `index.html`, or serve it (makes
the root-relative `/css`, `/img` paths behave exactly like in production):

```bash
cd ottomansfield
python3 -m http.server 8000
# then open http://localhost:8000
```

## how it is deployed now

the site is served from the mac mini: LXC 103 on the proxmox box, nginx, exposed
through the existing cloudflare tunnel. push changes with:

```bash
./deploy.sh            # copy to the box and reload nginx
./deploy.sh --git      # also commit and push to github first
```

`/data/celler.json` is not part of this repo's deploy. the celle scanner bot
writes it straight to `/var/www/celler` on the box and nginx serves that path,
so the live list updates on its own.

github pages is still set up on the repo as a fallback, but DNS points at the
tunnel, so the mac mini is what answers.

## original deploy checklist (kept for reference)

the site is static, so it deploys free with a custom domain anywhere:

1. **register the domain** `ottomansfield.com` (namecheap, cloudflare registrar,
   porkbun, whoever). this is the only part that costs money.
2. **pick a host** and push these files at the repo root:
   - **cloudflare pages** (free) — connect a git repo, no build command, output
     dir `/`. add the custom domain in the dashboard.
   - **github pages** (free) — push the repo, enable pages on `main`, root
     folder. the `CNAME` file is already set.
   - **netlify** (free) — drag-and-drop the folder, or connect the repo.
   - **neocities** (needs the $5/mo supporter plan for a custom domain).
3. **point dns** at the host (each host shows the exact records). give it a bit
   to propagate.
4. done. open `https://ottomansfield.com`.

paths are root-relative (`/css/...`, `/img/...`) so the same files work on a
host preview (`*.pages.dev`, `*.github.io`) and on the custom domain.

## editing the site

- **the intro text**: edit the `.box` in `index.html`. just change the words.
- **the links**: edit the `.links` list in `index.html`.
- **colors / accent**: open `css/style.css` and edit the `:root` block at the
  top. it's one muted teal accent; there are two alt accents (amber, green) in a
  comment right there. changing `--accent` / `--link` / `--link-hover` re-skins
  the whole site.
- **new pages**: copy the `HEADER` and `FOOTER` blocks (marked with comments in
  `index.html`) into a new file under `pages/`, reuse the same stylesheet.

## notes

- favicon is original (a small pixel "o" in the site accent). no borrowed or
  hotlinked assets.
- intentionally minimal for v1: just an intro and a few links. mascot, status
  box, counter, button wall, and guestbook were left out on purpose.
