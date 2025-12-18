# Week 2: Security Planning and Testing Methodology

## 1. Introduction
Following the infrastructure deployment in Week 1, this phase focuses on designing a robust security baseline and a standardized performance testing methodology. This planning ensures that all future configurations are deliberate, documented, and aligned with industry best practices for **Security by Design**.

## 2. Threat Modeling
To secure the headless server effectively, I have identified three primary threat vectors relevant to a remote-access Linux environment. The following model maps these threats to specific mitigation strategies I will implement in Weeks 4 and 5.

| ID | Threat | Description | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- | :--- |
| **T1** | **SSH Brute Force Attacks** | Automated bots attempting thousands of password guesses against Port 22. | **Critical:** Unauthorized root access; system compromise. | 1. Disable Password Authentication (Key-based only).<br>2. Implement **Fail2Ban** to ban repeated failures.<br>3. Restrict SSH access to the specific Workstation IP only. |
| **T2** | **Privilege Escalation** | An attacker with low-level user access exploiting vulnerabilities to gain Root privileges. | **High:** Full control over the OS kernel and file system. | 1. Disable remote Root login `PermitRootLogin no`.<br>2. Use `sudo` for administrative tasks.<br>3. Enforce **AppArmor** profiles to restrict process capabilities. |
| **T3** | **Unpatched Software Vulnerabilities** | Exploiting known CVEs in outdated services, e.g., old SSH or Kernel versions. | **High:** Remote Code Execution (RCE) or Denial of Service. | 1. Configure **Unattended-Upgrades** for automatic security patching.<br>2. Minimize attack surface by installing only required packages (Headless/Minimal install). |

## 3. Security Configuration Checklist
This checklist defines the "Golden Image" standard for the server. All configurations will be verified using a custom audit script in Week 5.

### A. Network & Firewall (UFW)
- [ ] **Default Policy:** Deny Incoming / Allow Outgoing.
- [ ] **SSH Access:** Allow Port 22 *ONLY* from Workstation IP (`192.168.56.6`).
- [ ] **Logging:** Enable UFW logging (Low).
- [ ] **ICMP:** Allow Echo Requests (Ping) for internal diagnostics.

### B. SSH Hardening (`/etc/ssh/sshd_config`)
- [ ] **Protocol:** Protocol 2 only.
- [ ] **Root Login:** `PermitRootLogin no` (Mandatory).
- [ ] **Authentication:** `PasswordAuthentication no` (Force Public Key Auth).
- [ ] **Empty Passwords:** `PermitEmptyPasswords no`.
- [ ] **Max Tries:** `MaxAuthTries 3` (Limits guessing attempts).

### C. Access Control & User Management
- [ ] **Root Account:** Lock root password `passwd -l root`.
- [ ] **Admin User:** Create dedicated `adminuser` with sudo privileges.
- [ ] **MAC System:** Enable **AppArmor** service at boot.
- [ ] **Sudoers:** Configure `sudo` to require password re-entry for critical commands.

### D. System Maintenance
- [ ] **Updates:** Install `unattended-upgrades` package.
- [ ] **Configuration:** Enable automatic installation of "Security" updates only.
- [ ] **Reboot:** Configure automatic reboot at 03:00 AM if kernel updates require it.

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
| **Network Latency** | `ping -c 5 <IP>` | Measures round-trip time between Workstation and Server. |

## 5. Learning Reflection
Defining the threat model first highlighted the importance of defense in depth. I realized that relying solely on a firewall is insufficient; if an attacker bypasses the IP restriction, the secondary layer of SSH Key Authentication serves as the critical backstop. This planning phase has shifted my mindset from "making it work" to making it secure by design.

---
[← Previous: Week 1](./week1.md) | [Return to Home](./index.md) | [Next: Week 3 →](./week3.md)
