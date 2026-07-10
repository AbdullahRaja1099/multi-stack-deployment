#!/usr/bin/env bash
# Installs Apache, Nginx, Tomcat 10, Java 17, Maven, Python, Node.
# Run once, with sudo, on a fresh Ubuntu host.
set -euo pipefail

sudo apt update && sudo apt upgrade -y

# --- Apache ---
sudo apt install -y apache2
sudo a2enmod proxy proxy_http rewrite ssl headers
sudo systemctl enable --now apache2

# Move Apache off port 80 so Nginx can own it (idempotent — safe to re-run)
sudo sed -i 's/^Listen 80$/Listen 8081/' /etc/apache2/ports.conf
sudo sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8081>/' /etc/apache2/sites-available/000-default.conf
sudo apache2ctl configtest
sudo systemctl restart apache2

# --- Nginx ---
sudo apt install -y nginx
sudo systemctl enable --now nginx

# --- Java + Maven + Tomcat 10 ---
sudo apt install -y openjdk-17-jdk maven

if [ ! -d /opt/tomcat10 ]; then
  cd /opt
  sudo wget -q https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.34/bin/apache-tomcat-10.1.34.tar.gz
  sudo tar xzf apache-tomcat-10.1.34.tar.gz
  sudo mv apache-tomcat-10.1.34 tomcat10
  sudo rm apache-tomcat-10.1.34.tar.gz
  sudo useradd -m -U -d /opt/tomcat10 -s /bin/false tomcat || true
  sudo chown -R tomcat:tomcat /opt/tomcat10
  sudo chmod +x /opt/tomcat10/bin/*.sh
fi

# --- Python ---
sudo apt install -y python3-venv python3-pip

# --- Node ---
sudo apt install -y nodejs npm

echo "Base servers installed. Next: run scripts/02-deploy-python.sh etc."
