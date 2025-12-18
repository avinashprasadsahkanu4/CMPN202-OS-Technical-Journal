# Week 3: Application Selection for Performance Testing

## 1. Introduction
In​‍​‌‍​‍‌ Phase 3, I chose and implemented a set of tools for creating different types of workload profiles (CPU, Memory, I/O, and Network). The main points for choosing these tools were **reproducibility**, **granularity** (the ability to precisely control the load), and **industry relevance**. These utilities are going to be the foundation of the quantitative performance analysis in Week ​‍​‌‍​‍‌6.

## 2. Application Selection Matrix
The following applications were chosen to represent the diverse workload types required by the assessment brief.

| Workload Type | Application Selected | Justification for Selection |
| :--- | :--- | :--- |
| **CPU-Intensive** | **stress-ng** | Industry-standard stress testing tool. Unlike simple loops, `stress-ng` can target specific CPU instructions (int, float, double), allowing for precise, reproducible synthetic load generation. |
| **RAM-Intensive** | **stress-ng (--vm)** | Capable of aggressively exercising the virtual memory subsystem (`--vm`), forcing page faults and swap usage to test memory pressure limits. |
| **Disk I/O** | **sysbench** | A scriptable multi-threaded benchmark tool. I chose this over `dd` because `sysbench` can simulate random read/write access patterns, which better reflect real-world server database behaviour. |
| **Network-Intensive** | **iperf3** | The standard tool for measuring active TCP/UDP bandwidth. It allows measuring maximum throughput independently of disk speed. |
| **Server Service** | **Nginx** | A high-performance web server. I selected Nginx over Apache for its event-driven architecture, which is more resource-efficient (Sustainability), making it ideal for our lightweight headless server. |

## 3. Installation Documentation
All installations were performed via SSH using the `apt` package manager on Ubuntu 24.04 LTS.

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
<img width="1137" height="596" alt="Screenshot 2025-12-18 133534" src="https://github.com/user-attachments/assets/287aabbd-d845-47ad-93b7-33781ef06d2e" />

### C. Service Configuration (Nginx and iperf3)
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

```bash
iperf3 -s
```
<img width="1072" height="104" alt="image" src="https://github.com/user-attachments/assets/2625bcb5-7abb-4553-b890-e7a46efebad2" />

**Verification that tools are installed and the `nginx` and `iperf3` services are active.**

## 4. Expected Resource Profiles
Based on the documentation for these tools, I have projected the expected resource impact during the Week 6 testing phase.

| Application | Primary Resource Impact | Secondary Impact | Expected Behaviour |
| :--- | :--- | :--- | :--- |
| **stress-ng --cpu 2** | CPU (100%) | Thermal / Power | System load average will rise to ~2.0. Responsiveness may lag. |
| **stress-ng --vm 2** | RAM (>80%) | Disk (Swap) | High memory pressure will force pages to swap, potentially causing "thrashing" if pushed too far. |
| **sysbench fileio** | Disk I/O | CPU (Wait) | High "iowait" times in CPU metrics. System responsiveness will drop significantly due to bus saturation. |
| **Nginx (Load Test)** | Network I/O | CPU (Softirq) | High network throughput with moderate CPU usage for interrupt handling. |

## 5. Monitoring Strategy
To measure the impact of these applications, I will utilize the following remote monitoring strategy. All data will be captured from the Workstation to minimize observer effect on the target server.

### A. Real-Time Monitoring (Qualitative)

<img width="2376" height="1389" alt="image" src="https://github.com/user-attachments/assets/dc0b19fe-0185-4719-898b-15f941502cde" />

* **Tool:** `htop` via SSH.
* **Purpose:** Visual confirmation that the correct resource is being stressed during the test.

### B. Data Logging (Quantitative)
I will execute the following commands via a remote script (`monitor-server.sh`) to capture raw data for analysis:

1.  **CPU Metrics:** `mpstat 1 10`
    * **Metric:** `%usr` (Application load) vs `%sys` (Kernel overhead).
2.  **Memory Metrics:** `vmstat 1 10`
    * **Metric:** `swpd` (Swap used) and `free` (Physical RAM).
3.  **Disk Metrics:** `iostat -xz 1 10`
    * **Metric:** `r/s` (Reads per sec) and `%util` (Device saturation).

## 6. Critical Reflection
Phase​‍​‌‍​‍‌ 3 was a moment of transition from physical infrastructure setup to the next big step - designing a foolproof experiment. One important insight that we took out of this week was the significance of deterministic testing.

### A. The Build vs. Buy Decision in Tool Selection

In the beginning, I had the idea of programming some rudimentary Python scripts for creating the CPU load. However, I concluded that this method is not scientifically reproducible because a loop could execute differently depending on the version of the Python interpreter. The result was the resort to **`stress-ng`** and **`sysbench`**. These are the industry standard tools that make it possible to precisely pinpoint the CPU instructions and memory methods one wants to use, thus assuring me that the performance data in Week 6 will be consistent and comparable.

### B. Sustainability Considerations

Choosing **Nginx** over Apache was not only a technical decision but also a conscious move towards the sustainability theme of this module. At present, the electricity consumption of data centres is equivalent to ~1% of the global total. Comparing the two architectures, Nginx's asynchronous, event-driven one usually requires less memory and CPU per concurrent connection than Apache's process-driven model. Hence, my choice of Nginx is a step in the right direction when it comes to energy optimization of the simulated infrastructure.

### C. The Observer Effect Challenge

Coming up with the monitoring strategy got me thinking about the Observer Effect, which is the risk that the monitoring tool itself becomes a consumer of the resources it is trying to measure. This has, in fact, confirmed the architectural decision that I made of having a completely separate **Workstation** for data acquisition. The Workstation runs the heavy SSH client, data logging, visualization, while the server only performs the lightweight probes `mpstat`, `iostat`; thus, the measurement overhead is minimized and the data correspond to the application's performance rather than the monitoring tool's ​‍​‌‍​‍‌cost.

---

[← Previous: Week 2](./week2.md) | [Return to Home](./index.md) | [Next: Week 4 →](./week4.md)

