# Week 4: Initial System Configuration & Security Implementation

## 1. Introduction
Phase​‍​‌‍​‍‌ 4 essentially represents the realization of the preparation work that has gone before. It was in this phase that I put in place the basement security measures that had been sketched out in Week 2. The server was to be fortified in such a tight manner that the removal of passwords and the granting of remote access only to the administrator's workstation would suffice for the network security.

**Administrative Constraint:** In accordance with the assessment brief, all the changes described below have been executed through SSH remotely. 

## 2. User Privilege Management

In order to fully comply with the Principle of Least Privilege, the default user was replaced with a separate administrative ​‍​‌‍​‍‌account.

**Implementation Steps:**
1.​‍​‌‍​‍‌ A new user `adminuser` was created to distinguish administrative actions from system service accounts.
2. The `adminuser` was given membership to the `sudo` group to grant elevated privileges.
3. **Security Impact:** In this way, root account direct logins are disallowed, and all administrative actions are recorded and can be traced ​‍​‌‍​‍‌back.

```bash
sudo adduser adminuser
sudo usermod -aG sudo adminuser
```
<img width="912" height="509" alt="image" src="https://github.com/user-attachments/assets/d0567f26-9a9b-49d9-881d-86851076b08b" />

## 3. SSH Configuration & Hardening

### A. Key-Based Authentication Implementation
I generated an **Ed25519** key pair on the workstation (chosen for its superior performance and security over RSA) and deployed the public key to the server.

```bash
ssh-keygen -t ed25519 -C "admin_access"
```
<img width="973" height="417" alt="image" src="https://github.com/user-attachments/assets/f300a8e6-f545-49b2-81a8-882d4282e6df" />

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub adminuser@192.168.56.6
```
<img width="1085" height="280" alt="image" src="https://github.com/user-attachments/assets/cd921fc6-7207-4165-a433-ad499dca9e52" />

```bash
ssh adminuser@192.168.56.6
```
<img width="933" height="612" alt="image" src="https://github.com/user-attachments/assets/9ceb4b05-e3c9-42c5-a328-926bafa3d9a7" />

**Successful SSH login using public key authentication, no password prompt.**

### B. Configuration Hardening (Before/After)
I modified `/etc/ssh/sshd_config` to disable insecure access methods.

| Setting | Before Value | After Value | Rationale |
| :--- | :--- | :--- | :--- |
| **PermitRootLogin** | `yes` (implied) | `no` | Prevents direct brute-force attacks on the known 'root' username. |
| **PasswordAuthentication** | `yes` | `no` | Eliminates the risk of weak password guessing; requires possession of the private key. |

**Configuration Evidence:**
The screenshots below demonstrate the state of `sshd_config` before and after hardening.

**State: Before Hardening (Insecure)**
```bash
sudo grep -E "PermitRootLogin|PasswordAuthentication" /etc/ssh/sshd_config
```
<img width="1071" height="155" alt="image" src="https://github.com/user-attachments/assets/f38ed171-a6c2-4248-92a4-ba5634e6123a" />

**State: After Hardening (Secure)**
```bash
sudo nano /etc/ssh/sshd_config
```
```yaml
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

```bash
sudo systemctl restart ssh
```
<img width="1040" height="178" alt="image" src="https://github.com/user-attachments/assets/fea87fe1-8bd4-4da3-92d9-9d653a8afc19" />


## 4. Firewall Configuration (UFW)
I configured the Uncomplicated Firewall (UFW) to implement a "Default Deny" policy, permitting traffic strictly from the Workstation IP.

### Firewall Ruleset
* **Default Incoming:** `DENY` (Blocks all traffic by default)
* **Default Outgoing:** `ALLOW` (Allows updates/patches)
* **Rule 1:** Allow TCP Port 22 *ONLY* (Workstation)

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 192.168.56.6 to any port 22
sudo ufw enable
```
<img width="897" height="242" alt="image" src="https://github.com/user-attachments/assets/21ab557c-0c43-42b4-8b2f-f67a64d1b749" />

```bash
sudo ufw status numbered
```
<img width="720" height="183" alt="image" src="https://github.com/user-attachments/assets/406d2137-c037-4abc-9af1-5f653df5aff6" />

**`sudo ufw status` numbered showing the strict allow rule for the Workstation IP.**

## 5. Learning Reflection
One​‍​‌‍​‍‌ critical risk of lockout came from implementing these controls remotely through SSH. For instance, if I had turned the firewall on without my IP check or if I had switched off password authentication without my key test, the headless server would have been inaccessible to me. This was again a strong professional lesson of Test, then Apply. Before I changed the **sshd_config** to disable passwords, I checked the SSH key connection in a separate terminal ​‍​‌‍​‍‌window.


[← Previous: Week 3](./week3.md) | [Return to Home](./index.md) | [Next: Week 5 →](./week5.md)

---
