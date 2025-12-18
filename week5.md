# Week 5: Advanced Security and Monitoring Infrastructure

## 1. Introduction
By the end of phase 5, I had enhanced the system's security level from the ground of firewall to **active intrusion detection** and **mandatory access control**. Furthermore, I set up the automation infrastructure necessary for checking these controls and system status monitoring from a distance.

## 2. Advanced Security Implementation

### A. Access Control (AppArmor)
I​‍​‌‍​‍‌ checked and set up **AppArmor** so that it limits what programs can do. In contrast to the usual Linux permissions (DAC), AppArmor has profiles that guarantee even compromised applications cannot open files outside their limited area.

```bash
sudo apt update
```
<img width="849" height="215" alt="image" src="https://github.com/user-attachments/assets/887630e8-bb80-4d9e-a390-29530afc7656" />

```bash
sudo apt install apparmor-utils -y
```
<img width="1688" height="1130" alt="image" src="https://github.com/user-attachments/assets/6ff41625-5cd8-4cff-bf16-47db49d33a95" />

```bash
sudo aa-status
```
<img width="719" height="1377" alt="image" src="https://github.com/user-attachments/assets/c9677446-f6a3-4fdb-9cc1-24b07d54b0dd" />

**`aa-status` showing profiles in 'enforce' mode.**

### B. Automatic Security Updates
To mitigate the risk of unpatched vulnerabilities (Threat T3), I configured `unattended-upgrades`.
* **Configuration:** Set to install "Security" updates automatically.
* **Reboot Policy:** Configured to reboot automatically at 02:00 if kernel updates are applied.

```bash
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades
```
<img width="1112" height="220" alt="image" src="https://github.com/user-attachments/assets/9b7f491e-9617-4652-8360-016586601c24" />
<img width="1129" height="707" alt="Screenshot 2025-12-18 143928" src="https://github.com/user-attachments/assets/c78e71c6-0aea-4ea3-be05-31bfed5c7833" />

```bash
systemctl status unattended-upgrades
```
<img width="1153" height="423" alt="image" src="https://github.com/user-attachments/assets/06e9625a-ff01-4de5-98d1-9ae88d27a439" />

**Service status showing `unattended-upgrades` is active.**

### C. Intrusion Detection (Fail2Ban)
I installed and configured **Fail2Ban** to monitor authentication logs.
* **Trigger:** 5 failed SSH login attempts within 10 minutes.
* **Action:** Ban the offending IP address for 1 hour.
* **Jail Config:** Copied `jail.conf` to `jail.local` to preserve settings during updates.

```bash
sudo apt install fail2ban -y
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo systemctl restart fail2ban
sudo fail2ban-client status sshd
```
<img width="1081" height="338" alt="image" src="https://github.com/user-attachments/assets/511aec50-614b-4654-a08d-6522cd391fcc" />

**`fail2ban-client` confirms the SSHD jail is currently monitoring log files.**

## 3. Automation & Scripting

### A. Security Baseline Script (`security-baseline.sh`)
I wrote a Bash script that is planned to be placed on a server. This program acts as a self-auditor; its main purpose is to check whether all security controls of Weeks 4 and 5 still ​‍​‌‍​‍‌exist.

```bash
nano ~/security-baseline.sh
```

**Script Source Code:**
```yaml
#!/bin/bash

echo "--- STARTING SECURITY AUDIT ---"

# 1. Check Firewall (UFW) Status
# Grep looks for 'active' in the status output
if sudo ufw status | grep -q "Status: active"; then
    echo " [OK] Firewall is ACTIVE."
else
    echo " [FAIL] Firewall is INACTIVE."
fi

# 2. Check SSH Root Login Configuration
# Check if PermitRootLogin is set to 'no' in the config
if sudo grep -q "PermitRootLogin no" /etc/ssh/sshd_config; then
    echo " [OK] SSH Root Login is DISABLED."
else
    echo " [FAIL] SSH Root Login might be ENABLED."
fi

# 3. Check AppArmor Status
# Check if the AppArmor module is loaded
if sudo aa-status --enabled; then
    echo " [OK] AppArmor is ENABLED."
else
    echo " [FAIL] AppArmor is NOT ACTIVE."
fi

echo "--- AUDIT COMPLETE ---"
```

```bash
chmod +x ~/security-baseline.sh
./security-baseline.sh
```
<img width="838" height="420" alt="image" src="https://github.com/user-attachments/assets/cbf8ac48-e2dd-4a87-94e4-31606664d15c" />

### B. Remote Monitoring Script (`monitor-server.sh`)
I came up with an idea to write a program that runs on the client-side and gathers performance data through SSH. This means that I will be able to keep an eye on the server even if I don't have a terminal window open all the time.

**Script Source Code:**
```yaml
#!/bin/bash
TARGET_USER="adminuser"
TARGET_IP="192.168.56.6"

echo "--- CONNECTING TO SERVER: $TARGET_IP ---"

# 1. Get Memory Usage
echo "[*] Memory Usage (MB):"
ssh $TARGET_USER@$TARGET_IP "free -m | grep Mem | awk '{print \$3}'"

# 2. Get Disk Usage
echo "[*] Disk Usage (Root):"
ssh $TARGET_USER@$TARGET_IP "df -h / | awk 'NR==2 {print \$5}'"
```

```bash
nano ./monitor-server.sh
chmod +x monitor-server.sh
./monitor-server.sh
```
<img width="705" height="280" alt="image" src="https://github.com/user-attachments/assets/774ccffe-d502-4745-89fe-969bf68c334b" />

## 4. Learning Reflection
When working on the `security-baseline.sh` script, I came to realize how invaluable Infrastructure as Code is. Rather than physically performing setting checks each week, now I have a tool that provides me a pass/fail indication within seconds. This minimizes human mistakes, and if a configuration is changed without authorization (configuration drift), the next audit will uncover it instantly.


---
[← Previous: Week 4](./week4.md) | [Return to Home](./index.md) | [Next: Week 6 →](./week6.md)

