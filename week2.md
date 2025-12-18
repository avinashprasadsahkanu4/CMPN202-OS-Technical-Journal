# Week 2: Security Planning and Testing Methodology

## 1. Introduction
After​‍​‌‍​‍‌ the Week 1 infrastructure rollout, the focus is shifted to establishing a strong security baseline and performance testing standard. Such planning makes sure that all subsequent configurations are intentional, recorded, and conform to the recent industry standards for **Security by ​‍​‌‍​‍‌Design**.

## 2. Threat Modeling
For​‍​‌‍​‍‌ the effective securing of the headless server, I have pinpointed three main threat vectors that are characteristic of a remote-access Linux environment. The diagram below associates these threats with the exact mitigation strategies that I am going to carry out in Weeks 4 and ​‍​‌‍​‍‌5.

| ID | Threat | Description | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- | :--- |
| **T1** | **SSH Brute Force Attacks** | Automated bots attempting thousands of password guesses against Port 22. | **Critical:** Unauthorized root access; system compromise. | 1. Disable Password Authentication (Key-based only).<br>2. Implement **Fail2Ban** to ban repeated failures.<br>3. Restrict SSH access to the specific Workstation IP only. |
| **T2** | **Privilege Escalation** | An attacker with low-level user access exploiting vulnerabilities to gain Root privileges. | **High:** Full control over the OS kernel and file system. | 1. Disable remote Root login `PermitRootLogin no`.<br>2. Use `sudo` for administrative tasks.<br>3. Enforce **AppArmor** profiles to restrict process capabilities. |
| **T3** | **Unpatched Software Vulnerabilities** | Exploiting known CVEs in outdated services, e.g., old SSH or Kernel versions. | **High:** Remote Code Execution (RCE) or Denial of Service. | 1. Configure **Unattended-Upgrades** for automatic security patching.<br>2. Minimize attack surface by installing only required packages (Headless/Minimal install). |

## 3. Security Configuration Checklist
This checklist defines the "Golden Image" standard for the server. All configurations will be verified using a custom audit script in Week 5.

### A. Network & Firewall (UFW)
-  **Default Policy:** Deny Incoming / Allow Outgoing.
-  **SSH Access:** Allow Port 22 *ONLY* from Workstation IP `192.168.56.6`.
-  **Logging:** Enable UFW logging (Low).
-  **ICMP:** Allow Echo Requests (Ping) for internal diagnostics.

### B. SSH Hardening (`/etc/ssh/sshd_config`)
-  **Protocol:** Protocol 2 only.
-  **Root Login:** `PermitRootLogin no` (Mandatory).
-  **Authentication:** `PasswordAuthentication no` (Force Public Key Auth).
-  **Empty Passwords:** `PermitEmptyPasswords no`.
-  **Max Tries:** `MaxAuthTries 3` (Limits guessing attempts).

### C. Access Control & User Management
-  **Root Account:** Lock root password `passwd -l root`.
<img width="451" height="78" alt="image" src="https://github.com/user-attachments/assets/e67bc1f4-67cc-4198-9c90-66e72cd1688c" />

-  **Admin User:** Createa  dedicated `adminuser` with sudo privileges.
-  **MAC System:** Enable **AppArmor** service at boot.
-  **Sudoers:** Configure `sudo` to require password re-entry for critical commands.

### D. System Maintenance
-  **Updates:** Install `unattended-upgrades` package.
-  **Configuration:** Enable automatic installation of "Security" updates only.
-  **Reboot:** Configure automatic reboot at 03:00 AM if kernel updates require it.

## 4. Performance Testing Methodology
To critically evaluate the operating system's behaviour under load, I have designed a comparative testing strategy.

### A. Testing Approach
Testing will be conducted in two states:
1.  **Baseline State:** System idle with only default services (SSH, Systemd) running.
2.  **Load State:** System under synthetic stress (CPU/RAM) or application load (Web Server).

### B. Remote Monitoring Strategy
Per the "Remote Administration" requirement, all metrics will be captured from the Workstation via SSH, preventing the monitoring tool itself from skewing the server's resource usage (Observation Bias).

**Tools Selected:**
* **Metric Collection:** Custom Bash script `monitor-server.sh` using `vmstat`, `mpstat`, and `free`.
* **Load Generation:** `stress-ng` for synthetic CPU/RAM stress and ApacheBench `ab` for network I/O.
* **Visualization:** `htop` (for real-time observation during demonstrations).

### C. Key Performance Indicators (KPIs)
| Metric | Command | Rationale |
| :--- | :--- | :--- |
| **CPU Usage (%)** | `mpstat 1 5` | Measures User vs. System time overhead. |
| **Memory Used (MB)** | `free -m` | Tracks RAM saturation and Swap usage. |
| **Disk I/O** | `iostat -xz 1 5` | Critical for identifying storage bottlenecks. |
| **Network Latency** | `ping -c 5 192.168.56.6` | Measures round-trip time between Workstation and Server. |

## 5. Baseline Security Analysis (Current State)
Before implementing the security plan, I conducted an audit of the current system state to validate the threat model.

### A. Firewall Status
The following command confirms that the firewall is currently inactive, leaving the system exposed to all incoming traffic on the local network.

```bash
sudo ufw status verbose
```
<img width="574" height="83" alt="image" src="https://github.com/user-attachments/assets/4758ae28-5909-4ab3-a710-7af0f672123c" />

**The Uncomplicated Firewall (UFW) is inactive by default.**

### B. Network Attack Surface
Scanning the listening ports reveals that SSH (Port 22) is open and listening on all interfaces (`0.0.0.0`), confirming it is the primary vector for potential brute-force attacks.

```bash
ss -tuln
```
<img width="1232" height="303" alt="image" src="https://github.com/user-attachments/assets/234550e2-0d05-434c-8c4d-8cd4e59e59a8" />

**`ss` output showing Port 22 in LISTEN state.**

### C. SSH Configuration Vulnerabilities
An inspection of the default SSH configuration confirms that **Root Login** and **Password Authentication** are both enabled. This critical vulnerability allows attackers to attempt brute-force login directly against the root account.

```bash
grep -nE "PermitRootLogin|PasswordAuthentication" /etc/ssh/sshd_config
```
<img width="1185" height="197" alt="image" src="https://github.com/user-attachments/assets/05a1ef9c-3103-49d0-8ede-0fc22308eb60" />

**Default `sshd_config` allows Root login and Password authentication.**

## 6. Learning Reflection
The​‍​‌‍​‍‌ first step in defining the threat model revealed to me that defense in depth was crucial. I understood that just having a firewall was not enough; if an attacker somehow gets around the IP restriction, the next layer of SSH Key Authentication will be the essential rescue. This effort phase has changed my thinking from just getting it to work to making it secure by ​‍​‌‍​‍‌design.

---
[← Previous: Week 1](./week1.md) | [Return to Home](./index.md) | [Next: Week 3 →](./week3.md)
