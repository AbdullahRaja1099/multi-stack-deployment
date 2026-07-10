#!/usr/bin/env bash
# Builds java-app/ (from this repo) with Maven and deploys the WAR to Tomcat.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$REPO_ROOT/java-app"

cd "$APP_DIR"
mvn clean package

sudo cp target/javaapp.war /opt/tomcat10/webapps/

sudo cp "$REPO_ROOT/tomcat-config/tomcat.service" /etc/systemd/system/tomcat.service
sudo systemctl daemon-reload
sudo systemctl enable --now tomcat
sudo systemctl restart tomcat

echo "Java app deployed. Test: curl http://localhost:8080/javaapp/"
