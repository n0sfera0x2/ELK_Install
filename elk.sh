#!/bin/bash
set -e

echo "[1/7] Installing dependencies..."
apt-get update
apt-get install -y apt-transport-https gnupg curl wget

echo "[2/7] Importing Elasticsearch GPG key..."
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

echo "[3/7] Adding Elasticsearch 9.x APT repo..."
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/9.x/apt stable main" > /etc/apt/sources.list.d/elastic-9.x.list

echo "[4/7] Installing Elasticsearch..."
apt-get update
apt-get install -y elasticsearch

echo "[5/7] Configuring Elasticsearch (cluster.name, network.host)..."
ES_CONFIG="/etc/elasticsearch/elasticsearch.yml"
sed -i 's|#cluster.name: .*|cluster.name: elasticsearch-lab|' "$ES_CONFIG"
sed -i 's|#network.host: .*|network.host: 0.0.0.0|' "$ES_CONFIG"
sed -i 's|#transport.host: .*|transport.host: 0.0.0.0|' "$ES_CONFIG"

echo "[6/7] Enabling and starting Elasticsearch with systemd..."
systemctl daemon-reexec
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

echo "[7/7] Done! Waiting 10s before checking status..."
sleep 10
systemctl status elasticsearch.service --no-pager

echo
echo "🔐 To set the 'elastic' superuser password, run:"
echo "    /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic"
echo
echo "📄 To test connection, run after password is set:"
echo '    curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:YOUR_PASSWORD https://localhost:9200'
