#!/bin/bash
#Avinash Shah
# CMPN202 Security Baseline Verification Script

echo "--- STARTING SECURITY AUDIT ---"

# 1. Check Firewall (UFW) Status
echo "[*] Checking Firewall Status..."
# Grep looks for 'active' in the status output
if sudo ufw status | grep -q "Status: active"; then
    echo " [OK] Firewall is ACTIVE."
else
    echo " [FAIL] Firewall is INACTIVE."
fi

# 2. Check SSH Root Login Configuration
echo "[*] Checking SSH Root Login..."
# Check if PermitRootLogin is set to 'no' in the config
if sudo grep -q "PermitRootLogin no" /etc/ssh/sshd_config; then
    echo " [OK] SSH Root Login is DISABLED."
else
    echo " [FAIL] SSH Root Login might be ENABLED."
fi

# 3. Check AppArmor Status
echo "[*] Checking AppArmor Status..."
# Check if the AppArmor module is loaded
if sudo aa-status --enabled; then
    echo " [OK] AppArmor is ENABLED."
else
    echo " [FAIL] AppArmor is NOT ACTIVE."
fi

# 4. Check Fail2Ban Status
echo "[*] Checking Fail2Ban Jail..."
# Check if the sshd jail is running
if sudo fail2ban-client status sshd | grep -q "File list"; then
    echo " [OK] Fail2Ban SSHD Jail is RUNNING."
else
    echo " [FAIL] Fail2Ban is NOT monitoring SSH."
fi

echo "--- AUDIT COMPLETE ---"
