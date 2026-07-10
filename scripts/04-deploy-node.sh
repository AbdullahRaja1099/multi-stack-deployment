#!/usr/bin/env bash
# Installs deps for node-app/ (from this repo) and runs it as a systemd service.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$REPO_ROOT/node-app"

cd "$APP_DIR"
npm install

sudo chown -R www-data:www-data "$APP_DIR"

sudo cp "$APP_DIR/nodeapp.service" /etc/systemd/system/nodeapp.service
sudo systemctl daemon-reload
sudo systemctl enable --now nodeapp

echo "Node app deployed. Test: curl http://127.0.0.1:3000/"
