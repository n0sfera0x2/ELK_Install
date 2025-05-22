#!/bin/bash
set -e

echo "[1/3] Skipping dependency and GPG setup (assumed done via elastic.sh/kibana.sh)..."

APT_SOURCE="/etc/apt/sources.list.d/elastic-9.x.list"
EXPECTED_KEY="/usr/share/keyrings/elasticsearch-keyring.gpg"

if ! grep -q "$EXPECTED_KEY" "$APT_SOURCE" 2>/dev/null; then
    echo "ERROR: Elastic APT repo not found or mismatched keyring. Please run elastic.sh first."
    exit 1
fi

echo "[2/3] Installing Logstash..."
apt-get update
apt-get install -y logstash

echo "[3/3] Enabling and starting Logstash..."
systemctl enable logstash.service
systemctl start logstash.service

echo "✅ Logstash installed and running. To check status:"
echo "   sudo systemctl status logstash --no-pager"
