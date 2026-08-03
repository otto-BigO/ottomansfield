#!/usr/bin/env bash
#
# Publish the site to the Mac mini, which is what actually serves
# ottomansfield.com through the Cloudflare tunnel.
#
# The celle data is NOT copied. The bot writes it straight to /var/www/celler
# on the box, and nginx serves that as /data/, so it stays live on its own.
#
# Usage:
#   ./deploy.sh          copy the site and reload nginx
#   ./deploy.sh --git    also commit and push to GitHub first

set -euo pipefail

HOST="root@ottomacmini.tail38ffa0.ts.net"
CTID=103
WEB_ROOT=/var/www/ottomansfield

cd "$(dirname "$0")"

if [ "${1:-}" = "--git" ]; then
    echo "==> Committing and pushing"
    git add -A
    git diff --cached --quiet || git commit -q -m "Site update"
    git push -q origin main
    echo "    pushed"
fi

echo "==> Packing (data/ excluded, the bot owns that on the box)"
TAR=$(mktemp -t site).tar.gz
tar --exclude=.git --exclude=.DS_Store --exclude=data --exclude=deploy.sh \
    -czf "$TAR" . 2>/dev/null

echo "==> Copying"
scp -q -o BatchMode=yes "$TAR" "$HOST:/tmp/site-deploy.tar.gz"
rm -f "$TAR"

ssh -o BatchMode=yes "$HOST" "
set -e
pct push $CTID /tmp/site-deploy.tar.gz /tmp/site.tar.gz
rm -f /tmp/site-deploy.tar.gz
pct exec $CTID -- bash -lc '
  set -e
  mkdir -p $WEB_ROOT
  tar -xzf /tmp/site.tar.gz -C $WEB_ROOT
  rm -f /tmp/site.tar.gz
  chown -R www-data:www-data $WEB_ROOT
  nginx -t >/dev/null 2>&1 && systemctl reload nginx
  echo \"    nginx: \$(systemctl is-active nginx)\"
'
"

echo
echo "==> Checking the live site"
for p in / /pages/celler.html /data/celler.json /css/style.css; do
    printf "    %-22s http=%s\n" "$p" \
      "$(curl -sS --max-time 15 -o /dev/null -w '%{http_code}' "https://ottomansfield.com$p")"
done
echo
echo "Live: https://ottomansfield.com"
