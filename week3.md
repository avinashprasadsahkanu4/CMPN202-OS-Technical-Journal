# Week 3: Application Selection for Performance Testing

## 1. Introduction
In Phase 3, I selected and deployed a suite of applications to generate specific workload profiles (CPU, Memory, I/O, and Network). The selection criteria focused on **reproducibility**, **granularity** (the ability to fine-tune load), and **industry relevance**. [cite_start]These tools will form the basis of the quantitative performance analysis in Week 6[cite: 46].

## 2. Application Selection Matrix
The following applications were chosen to represent the diverse workload types required by the assessment brief.

| Workload Type | Application Selected | Justification for Selection |
| :--- | :--- | :--- |
| **CPU-Intensive** | **stress-ng** | Industry-standard stress testing tool. Unlike simple loops, `stress-ng` can target specific CPU instructions (int, float, double), allowing for precise, reproducible synthetic load generation. |
| **RAM-Intensive** | **stress-ng (--vm)** | Capable of aggressively exercising the virtual memory subsystem (`--vm`), forcing page faults and swap usage to test memory pressure limits. |
| **Disk I/O** | **sysbench** | A scriptable multi-threaded benchmark tool. I chose this over `dd` because `sysbench` can simulate random read/write access patterns, which better reflect real-world server database behaviour. |
| **Network-Intensive** | **iperf3** | The standard tool for measuring active TCP/UDP bandwidth. It allows measuring maximum throughput independently of disk speed. |
| **Server Service** | **Nginx** | A high-performance web server. [cite_start]I selected Nginx over Apache for its event-driven architecture, which is more resource-efficient (Sustainability), making it ideal for our lightweight headless server[cite: 46]. |

## 3. Installation Documentation
[cite_start]All installations were performed via SSH using the `apt` package manager on Ubuntu 24.04 LTS[cite: 47].

### A. System Update
Ensuring repository lists were current before installation.

```bash
sudo apt update
```
<img width="1268" height="469" alt="image" src="https://github.com/user-attachments/assets/a43ba6cf-785e-4b30-a40a-25b0f3a89392" />

```bash
sudo apt upgrade -y
```
<img width="1151" height="518" alt="image" src="https://github.com/user-attachments/assets/182c2625-d5dc-4fe2-a6ae-a49d043ce1a7" />

### B. Tool Installation
I installed the suite in a single pass to ensure dependency consistency.

```bash
sudo apt install stress-ng sysbench iperf3 nginx -y
```
<img width="1708" height="1066" alt="image" src="https://github.com/user-attachments/assets/71e16b58-86db-4ee5-a9fe-5e1307577cab" />

### C. Service Configuration (Nginx)
Nginx was enabled to start automatically on boot using systemd.

```bash
sudo systemctl enable nginx
sudo systemctl start nginx
```
<img width="1382" height="105" alt="image" src="https://github.com/user-attachments/assets/0f91edde-6743-4264-a26c-02e8e9e84664" />

```bash
stress-ng --version
```
<img width="1057" height="56" alt="image" src="https://github.com/user-attachments/assets/03cd4df1-61b5-47bb-a034-987f9b276649" />

```bash
systemctl status nginx
```
<img width="1143" height="463" alt="image" src="https://github.com/user-attachments/assets/34224d2a-dc12-4e7d-b54c-a3abc37b6f6e" />

**Verification that tools are installed and the Nginx service is active.**

## 4. Expected Resource Profiles
Based on the documentation for these tools, I have projected the expected resource impact during the Week 6 testing phase.

| Application | Primary Resource Impact | Secondary Impact | Expected Behaviour |
| :--- | :--- | :--- | :--- |
| **stress-ng --cpu 2** | CPU (100%) | Thermal / Power | System load average will rise to ~2.0. Responsiveness may lag. |
| **stress-ng --vm 2** | RAM (>80%) | Disk (Swap) | High memory pressure will force pages to swap, potentially causing "thrashing" if pushed too far. |
| **sysbench fileio** | Disk I/O | CPU (Wait) | High "iowait" times in CPU metrics. System responsiveness will drop significantly due to bus saturation. |
| **Nginx (Load Test)** | Network I/O | CPU (Softirq) | High network throughput with moderate CPU usage for interrupt handling. |

## 5. Monitoring Strategy
To measure the impact of these applications, I will utilize the following remote monitoring strategy. All data will be captured from the Workstation to minimize "observer effect" on the target server.

### A. Real-Time Monitoring (Qualitative)
* **Tool:** `htop` (via SSH).
* **Purpose:** Visual confirmation that the correct resource (e.g., CPU vs RAM) is being stressed during the test.

### B. Data Logging (Quantitative)
I will execute the following commands via a remote script (`monitor-server.sh`) to capture raw data for analysis:

1.  **CPU Metrics:** `mpstat 1 10`
    * **Metric:** `%usr` (Application load) vs `%sys` (Kernel overhead).
2.  **Memory Metrics:** `vmstat 1 10`
    * **Metric:** `swpd` (Swap used) and `free` (Physical RAM).
3.  **Disk Metrics:** `iostat -xz 1 10`
    * **Metric:** `r/s` (Reads per sec) and `%util` (Device saturation).

## 6. Critical Reflection
Phase 3 marked a shift from infrastructure setup to designing a rigorous testing methodology. A key realization this week was the importance of **deterministic testing**.

### A. The Build vs. Buy Decision in Tool Selection
Initially, I considered writing simple Python scripts to generate CPU load. However, I realized this approach lacks scientific reproducibility—a loop might execute differently depending on the Python interpreter version. This led to the selection of **`stress-ng`** and **`sysbench`**. These industry-standard tools allow for precise, granular control over specific CPU instructions and memory methods, ensuring that my performance data in Week 6 will be consistent and comparable.

### B. Sustainability Considerations
The choice of **Nginx** over Apache was a deliberate decision aligned with the module's sustainability theme. Data centres currently consume ~1% of global electricity. Nginx's asynchronous, event-driven architecture typically has a smaller memory footprint and lower CPU usage per concurrent connection compared to Apache's process-driven model. By selecting Nginx, I am optimizing the energy cost per request of this simulated infrastructure.

### C. The Observer Effect Challenge
Designing the monitoring strategy highlighted the "Observer Effect"—the risk that the monitoring tool itself consumes the resources it is trying to measure. This validated my architectural decision to use a separate **Workstation** for data collection. By running the heavy lifting SSH client, data logging, visualization on the Workstation and only executing lightweight probes `mpstat`, `iostat` on the server, I minimize the measurement overhead, ensuring the data accurately reflects the application's performance, not the monitoring tool's cost.

---

[← Previous: Week 2](./week2.md) | [Return to Home](./index.md) | [Next: Week 4 →](./week4.md)

