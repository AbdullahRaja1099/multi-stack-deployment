#!/usr/bin/env bash
# Deploys python-app/ (from this repo) behind Apache as a reverse proxy.
# Assumes this repo is cloned to /opt/multi-stack-deployment-lab.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$REPO_ROOT/python-app"

cd "$APP_DIR"
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate

sudo chown -R www-data:www-data "$APP_DIR"

sudo cp "$APP_DIR/pyapp.service" /etc/systemd/system/pyapp.service
sudo systemctl daemon-reload
sudo systemctl enable --now pyapp

sudo cp "$REPO_ROOT/apache-config/000-default.conf" /etc/apache2/sites-available/000-default.conf
sudo systemctl restart apache2

echo "Python app deployed. Test: curl http://localhost:8081/"
