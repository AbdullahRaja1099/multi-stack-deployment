#!/usr/bin/env bash
# Copies every nginx-config/*.conf from this repo into sites-available,
# enables them, adds local hostnames to /etc/hosts, and reloads nginx.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONF_DIR="$REPO_ROOT/nginx-config"

for conf in "$CONF_DIR"/*.conf; do
  name="$(basename "$conf")"
  sudo cp "$conf" "/etc/nginx/sites-available/$name"
  sudo ln -sf "/etc/nginx/sites-available/$name" "/etc/nginx/sites-enabled/$name"
done

# Local hostnames used by vhosts.conf, domain.conf, context-routing.conf, ssl.conf
HOSTS_LINE="127.0.0.1  python.lab.local java.lab.local node.lab.local app.lab.local routing.lab.local"
if ! grep -q "app.lab.local" /etc/hosts; then
  echo "$HOSTS_LINE" | sudo tee -a /etc/hosts > /dev/null
fi

sudo nginx -t
sudo systemctl reload nginx

echo "Nginx configs deployed and hostnames added to /etc/hosts."
