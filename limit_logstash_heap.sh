#!/bin/bash
set -e

#############################################
# Script: limit_logstash_heap.sh
# Purpose:
#   Reduce Logstash memory (heap) usage to 256 MB
#   on low-resource systems (e.g., lab or test VM)
# 
# What it does:
#   - Updates the JVM heap size settings for Logstash
#   - Restarts Logstash if it's enabled
#############################################

# Path to Logstash JVM options file
LS_OPTS="/etc/logstash/jvm.options"

echo "[1/2] Setting Logstash JVM heap size to 256 MB..."

# Use sed to replace the -Xms and -Xmx values with 256m
sudo sed -i 's/^-Xms[0-9]*[mgMG]/-Xms256m/' "$LS_OPTS"
sudo sed -i 's/^-Xmx[0-9]*[mgMG]/-Xmx256m/' "$LS_OPTS"

echo "[2/2] Restarting Logstash (only if enabled)..."

# Only restart Logstash if it's enabled
if systemctl is-enabled --quiet logstash; then
  sudo systemctl restart logstash
  echo "Logstash restarted with new heap settings."
else
  echo "Logstash is not enabled. No restart needed."
fi

echo "✅ Done. Logstash heap now limited to 256 MB."
