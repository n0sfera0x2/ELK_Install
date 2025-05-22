#!/bin/bash
set -e

echo "[1/6] Installing dependencies..."
apt-get update
apt-get install -y apt-transport-https curl gnupg

echo "[2/6] Adding Elastic GPG key (if not already added)..."
ELASTIC_KEY="/usr/share/keyrings/elasticsearch-keyring.gpg"
if [ ! -f "$ELASTIC_KEY" ]; then
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o "$ELASTIC_KEY"
else
    echo "Elastic GPG key already exists."
fi

echo "[3/6] Adding APT repo for Elastic 9.x (if not present)..."
REPO_FILE="/etc/apt/sources.list.d/elastic-9.x.list"
if ! grep -q "elastic.co/packages/9.x" "$REPO_FILE" 2>/dev/null; then
    echo "deb [signed-by=$ELASTIC_KEY] https://artifacts.elastic.co/packages/9.x/apt stable main" | tee "$REPO_FILE"
else
    echo "Elastic APT repo already configured."
fi

echo "[4/6] Installing Kibana..."
apt-get update
apt-get install -y kibana

echo "[5/6] Configuring Kibana to listen on all interfaces..."
KIBANA_CONFIG="/etc/kibana/kibana.yml"
sed -i 's|#server.host:.*|server.host: "0.0.0.0"|' "$KIBANA_CONFIG"

echo "[6/6] Enabling and starting Kibana service..."
systemctl daemon-reexec
systemctl enable kibana.service
systemctl start kibana.service

echo
echo "✅ Kibana installation complete."
echo
echo "🔐 If Kibana needs to enroll with Elasticsearch:"
echo "    On the Elasticsearch node, run:"
echo "        /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana"
echo "    Then visit http://<your-kibana-ip>:5601 to enroll Kibana."
echo
echo "📄 Config file: $KIBANA_CONFIG"
echo "🧪 Check status: systemctl status kibana --no-pager"
