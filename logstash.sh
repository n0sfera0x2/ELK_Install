#!/bin/bash
set -e

echo "[1/6] Installing required dependencies..."
apt-get update
apt-get install -y apt-transport-https curl gnupg

echo "[2/6] Adding Elastic GPG key (shared for all Elastic products)..."
ELASTIC_KEY="/usr/share/keyrings/elastic-keyring.gpg"
if [ ! -f "$ELASTIC_KEY" ]; then
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o "$ELASTIC_KEY"
else
    echo "Elastic GPG key already present."
fi

echo "[3/6] Adding APT repository for Elastic 9.x..."
LOGSTASH_REPO="/etc/apt/sources.list.d/elastic-9.x.list"
if ! grep -q "logstash" "$LOGSTASH_REPO" 2>/dev/null; then
    echo "deb [signed-by=$ELASTIC_KEY] https://artifacts.elastic.co/packages/9.x/apt stable main" | tee -a "$LOGSTASH_REPO"
else
    echo "Elastic APT repo already configured."
fi

echo "[4/6] Updating package list and installing Logstash..."
apt-get update
apt-get install -y logstash

echo "[5/6] Enabling and starting Logstash service..."
systemctl enable logstash.service
systemctl start logstash.service

echo "[6/6] Logstash installation complete. Service status:"
systemctl status logstash.service --no-pager
