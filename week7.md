# Week 7: Security Audit and System Evaluation

## 1. Introduction
The final phase of this project involved a comprehensive security audit to validate the configuration against industry standards. I utilized **Lynis** for host-based auditing and **Nmap** for network-based vulnerability scanning. This report documents the findings, remediations applied, and the final security posture of the server.

## 2. Infrastructure Security Assessment (Lynis)

I performed a deep compliance scan using Lynis. The audit evaluates key areas including authentication, firewalling, and file permissions.

### A. Initial Audit (Before Remediation)
The initial scan identified warnings regarding missing legal banners and file permission settings on the SSH configuration.
* **Initial Hardening Index:** 63

```bash
sudo apt update
sudo apt install lynis -y
sudo lynis audit system
```
<img width="915" height="778" alt="image" src="https://github.com/user-attachments/assets/f6a15a5a-dfb1-4379-9180-89ce07a3e06b" />

*Initial Lynis scan result showing the baseline score.*

### B. Remediation Actions
To improve the security posture and increase the hardening index, I applied the following advanced fixes based on Lynis recommendations:
1.  **System Auditing:** Installed `auditd` and `acct` packages. This enables the Linux Audit Framework to track security-relevant events and user actions, a critical requirement for high-security environments.
2.  **Shared Memory Hardening:** Modified `/etc/fstab` to mount `/run/shm` with `noexec` and `nosuid`. This prevents attackers from executing malicious binaries hidden in shared memory.
3.  **SSH Timeouts:** Configured `ClientAliveInterval 300` in `sshd_config` to automatically disconnect idle sessions after 5 minutes, reducing the risk of session hijacking.
4.  **Legal Banner:** Configured a warning banner (`/etc/issue.net`) to provide legal notice to unauthorized users.

### C. Final Audit (After Remediation)
A subsequent scan confirmed the effectiveness of these controls, resulting in a measurable improvement in the security score.

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

I conducted an external port scan from the workstation to verify the firewall rules implemented in Week 4.

**Command Executed:** `nmap -sV 192.168.56.6`

<img width="929" height="367" alt="image" src="https://github.com/user-attachments/assets/80a69bce-c163-4a69-a251-ce0055ecbfb6" />

**Nmap output showing that ONLY Port 22 (SSH) is accessible. All other ports are filtered/closed.**

**Analysis:**
The scan confirms that the **UFW Firewall** is correctly dropping unsolicited traffic. No unnecessary ports, like DNS/53 or MySQL/3306, are exposed to the external network, minimizing the attack surface.

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
Despite the hardening measures, the following risks remain and are accepted as part of the operational trade-offs.

| Risk ID | Vulnerability | Severity | Mitigation / Acceptance Rationale |
| :--- | :--- | :--- | :--- |
| **R1** | **Internal Thread** | Medium | A compromised Workstation key could allow access. **Mitigation:** The SSH key is passphrase-protected (simulated) and access is limited to a single IP. |
| **R2** | **Zero-Day Exploits** | Low | Unknown vulnerabilities in the Linux Kernel. **Mitigation:** `unattended-upgrades` ensures patches are applied immediately upon release. |
| **R3** | **DoS Attack** | Medium | The server can still be overwhelmed by traffic (Port 80). **Mitigation:** Rate limiting configured in Nginx helps, but upstream DDoS protection would be required for production. |

## 6. Project Conclusion
This coursework successfully demonstrated the deployment of a secure, sustainable, and high-performance Linux server. By strictly adhering to the **Headless** constraint and utilizing CLI tools for all administration, I have developed professional competencies in **Remote Management**, **Security Hardening**, and **Quantitative Performance Analysis**. The final audit confirms a system that is resilient by design, satisfying the module's security learning outcomes.

---
[← Previous: Week 6](./week6.md) | [Return to Home](./index.md)
