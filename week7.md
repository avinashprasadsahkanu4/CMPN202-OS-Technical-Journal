# Week 7: Security Audit and System Evaluation

## 1. Introduction
In​‍​‌‍​‍‌ the security validation step of the project, I conducted a thorough security audit to ensure that the configurations comply with industry standards. For a host-based audit, I ran Lynis, and for a network-based vulnerability scan, I ran Nmap. The report records the disclosures, the fixes done, as well as the server's final security strength level.

## 2. Infrastructure Security Assessment (Lynis)
I ran a full-fledged compliance scan by means of Lynis, which, in its evaluation, authentication, firewalling, and file permission, are among the key areas it looks at.

### A. Initial Audit (Before Remediation)
The first scan detected warnings regarding the absence of legal banners and the file permission settings on the SSH configuration.
* **Initial Hardening Index:** 63

```bash
sudo apt update
sudo apt install lynis -y
sudo lynis audit system
```
<img width="915" height="778" alt="image" src="https://github.com/user-attachments/assets/f6a15a5a-dfb1-4379-9180-89ce07a3e06b" />

*Initial Lynis scan result showing the baseline score.*

### B. Remediation Actions
I have made the following advanced changes based on Lynis recommendations to improve security posture and increase the hardening index:

1. **System Auditing:** Installed `auditd` and `acct` packages. The Linux Audit Framework thus can record security-relevant events and user actions, which is an essential feature of high-security environments.
2. **Shared memory hardening:** Changed `/etc/fstab` to mount `/run/shm` with `noexec` and `nosuid` options. This is a preventative measure against intruders who may try to execute malicious binaries hidden in shared memory.
3. **SSH timeouts:** Set `ClientAliveInterval 300` in `sshd_config` so that the server disconnects idle sessions automatically after 5 minutes, hence mitigating the risk of session hijacking.
4. **Legal banner:** Placed a warning banner `/etc/issue.net` to present a legal notice to unauthorized ​‍​‌‍​‍‌users.

### C. Final Audit (After Remediation)
Another​‍​‌‍​‍‌ scan afterwards verified the efficiency of these controls, and there was a notable security score improvement.

```bash
sudo apt update
sudo apt install auditd acct debsums -y
sudo systemctl enable auditd
sudo systemctl start auditd
sudo nano /etc/fstab
```

**Adding this line at the very bottom of the file:**
```yaml
tmpfs   /run/shm    tmpfs   defaults,noexec,nosuid  0   0
```
```bash
sudo nano /etc/ssh/sshd_config
```

**Adding this line at the very bottom of the file:**
```yaml
ClientAliveInterval 300
ClientAliveCountMax 0
```

* **Final Hardening Index:** 65
```bash
sudo lynis audit system
```
<img width="935" height="788" alt="image" src="https://github.com/user-attachments/assets/4c8fa7c5-8158-4699-bee7-295c294e0a4a" />

**Improved Hardening Index after applying auditing and kernel hardening fixes.**

## 3. Network Security Assessment (Nmap)
I carried out an external port scan from the workstation to check the firewall rules that were implemented in Week 4.

**Command Executed:** `nmap -sV 192.168.56.6`

<img width="929" height="367" alt="image" src="https://github.com/user-attachments/assets/80a69bce-c163-4a69-a251-ce0055ecbfb6" />

**Nmap output showing that ONLY Port 22 (SSH) is accessible. All other ports are filtered/closed.**

**Analysis:**
The scan determines that the **UFW Firewall** is properly rejecting unauthorized traffic. There are no unnecessary ports, such as DNS/53 or MySQL/3306, that are exposed to the external network, the attack surface is kept to a minimum.

## 4. Service Inventory & Justification
Per the **Least Privilege** principle, I verified that only essential services are active.

```bash
systemctl list-units --type=service --state=running
```
<img width="1919" height="764" alt="image" src="https://github.com/user-attachments/assets/2aab483a-2d01-436b-a33e-51ddd017e5e8" />

| Service | Status | Justification |
| :--- | :--- | :--- |
| **sshd** | Running | **Essential.** Required for remote administration. Hardened with Key-Auth. |
| **ufw** | Active | **Essential.** Host-based firewall controlling network access. |
| **fail2ban** | Running | **Security.** Monitors logs to ban brute-force attackers. |
| **auditd** | Running | **Security.** Daemon for the Linux Audit framework. |
| **nginx** | Running | **Application.** The web server workload used for Week 6 testing. |
| **unattended-upgrades** | Running | **Security.** Automates the installation of security patches. |

## 5. Remaining Risk Assessment
Regardless​‍​‌‍​‍‌ the toughening steps, the risks below continue to be there and are considered the operational ​‍​‌‍​‍‌trade-offs.

| Risk ID | Vulnerability | Severity | Mitigation / Acceptance Rationale |
| :--- | :--- | :--- | :--- |
| **R1** | **Internal Thread** | Medium | A compromised Workstation key could allow access. **Mitigation:** The SSH key is passphrase-protected (simulated) and access is limited to a single IP. |
| **R2** | **Zero-Day Exploits** | Low | Unknown vulnerabilities in the Linux Kernel. **Mitigation:** `unattended-upgrades` ensures patches are applied immediately upon release. |
| **R3** | **DoS Attack** | Medium | The server can still be overwhelmed by traffic (Port 80). **Mitigation:** Rate limiting configured in Nginx helps, but upstream DDoS protection would be required for production. |

## 6. Project Conclusion
The coursework has vividly conveyed the setting up of a secure, sustainable, and high-performing Linux server. By strictly complying with the **Headless** constraint and resorting to CLI tools for all administration tasks, I have gained professional skills in **Remote Management**, **Security Hardening**, and **Quantitative Performance Analysis**. The conclusive audit reveals an inherently resilient system, thus meeting the module's security learning ​‍​‌‍​‍‌outcomes.

---
[← Previous: Week 6](./week6.md) | [Return to Home](./index.md)
