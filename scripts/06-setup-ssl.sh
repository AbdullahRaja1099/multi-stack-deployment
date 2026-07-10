#!/usr/bin/env bash
# Generates a self-signed cert for app.lab.local, used by nginx-config/ssl.conf.
# For a real public domain, use certbot instead:
#   sudo apt install certbot python3-certbot-nginx
#   sudo certbot --nginx -d yourdomain.com
set -euo pipefail

sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/lab.key \
  -out /etc/nginx/ssl/lab.crt \
  -subj "/CN=app.lab.local"

sudo nginx -t
sudo systemctl reload nginx

echo "Self-signed cert created. Test: curl -k https://app.lab.local/"
