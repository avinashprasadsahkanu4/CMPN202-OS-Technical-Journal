#!/bin/bash
# CMPN202 Remote Server Monitoring Script

TARGET_USER="adminuser"
TARGET_IP="192.168.56.6"

echo "--- CONNECTING TO SERVER: $TARGET_IP ---"

# 1. Get Memory Usage
# We use 'free -m' to show memory in MB and awk to filter the output
echo "[*] Memory Usage (MB):"
ssh $TARGET_USER@$TARGET_IP "free -m | grep Mem | awk '{print \$3}'"

# 2. Get Disk Usage
# 'df -h' shows disk space, we filter for the root partition '/'
echo "[*] Disk Usage (Root):"
ssh $TARGET_USER@$TARGET_IP "df -h / | awk 'NR==2 {print \$5}'"

# 3. Get Load Average
# 'uptime' shows the system load averages for 1, 5, and 15 minutes
echo "[*] System Load:"
ssh $TARGET_USER@$TARGET_IP "uptime | awk -F'load average:' '{print \$2}'"

echo "--- MONITORING COMPLETE ---"
