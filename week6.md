
# Week 6: Performance Evaluation and Analysis

## 1. Introduction
In Phase 6, I executed the performance testing methodology designed in Week 3. The objective was to establish a quantitative baseline, identify system bottlenecks under load, and implement specific optimizations to improve efficiency and throughput.

## 2. Testing Methodology
All tests were executed on the server, with metrics captured remotely from the workstation to minimize observer bias.

* **Load Generator:** `stress-ng` (CPU/RAM) and `ab` (Web Server).
* **Monitoring Tool:** Custom SSH `vmstat` scripts.
* **Metrics:** CPU User %, Free Memory, Requests Per Second (RPS).

## 3. Performance Data & Analysis

### A. Baseline vs. Load Testing (Before Optimization)

| Metric | Baseline (Idle) | Under Stress (Load) | Impact Observed |
| :--- | :--- | :--- | :--- |
| **CPU Usage (%usr)** | 0-1% | 100% | System became unresponsive to SSH commands; Load avg > 2.0. |
| **Memory (Free)** | ~380 MB | < 50 MB | Significant drop in cache; system began swapping to disk. |
| **Nginx Throughput** | N/A | **850 req/sec** | (Initial Baseline for Web Traffic). |

```bash
ssh adminuser@192.168.56.6 "vmstat 1 5"
ssh adminuser@192.168.56.6 "vmstat 1 10"
```
<img width="1075" height="504" alt="image" src="https://github.com/user-attachments/assets/22d73164-450b-427b-ae79-6ff985a370f2" />

**`vmstat` output showing CPU saturation (us=100) during stress testing.**

```bash
sudo apt install apache2-utils -y
ab -n 1000 -c 10 http://127.0.0.1/
```
<img width="689" height="930" alt="image" src="https://github.com/user-attachments/assets/dc9459f3-07b1-4872-8ad4-db33331db485" />

**ApacheBench (`ab`) results showing initial requests per second.**

### B. Bottleneck Identification
Analysis of the load data revealed two primary bottlenecks:
1.  **Memory Swapping:** Under RAM pressure (`stress-ng --vm`), the system aggressively swapped to disk (default swappiness=60), causing I/O latency.
2.  **Concurrency Limit:** The Nginx default configuration limited `worker_connections` to 768, capping the theoretical maximum throughput for high-concurrency scenarios.

## 4. System Optimisation
To address these bottlenecks, I implemented two targeted improvements.

### Optimization 1: Reducing Swappiness (Sustainability)
I lowered `vm.swappiness` from the default **60** to **10**.
* **Rationale:** This tells the kernel to prefer keeping data in RAM (which is fast and low-power) rather than writing to the disk (which is slow and energy-intensive). This aligns with the **Sustainability** theme by reducing unnecessary disk I/O.
* **Command:** `sudo sysctl vm.swappiness=10`

### Optimization 2: Tuning Nginx Concurrency
I increased the Nginx `worker_connections` limit from **768** to **2048**.
* **Rationale:** This allows the web server to handle more simultaneous connections without rejecting users, improving service scalability.
* **Command:** `sed -i 's/768/2048/' /etc/nginx/nginx.conf`

<img width="1400" height="925" alt="image" src="https://github.com/user-attachments/assets/6f9d5a9d-2ed9-4825-936e-dfd4fed227ed" />

<img width="842" height="179" alt="image" src="https://github.com/user-attachments/assets/7dc928e6-adc4-4668-95c3-5a01b14f160f" />

<img width="631" height="49" alt="image" src="https://github.com/user-attachments/assets/c7fc6eed-aa85-462d-a148-f73bd95d2e8a" />

**Evidence: Verification of `sysctl` value and Nginx configuration changes.**

## 5. Post-Optimization Results

After applying the fixes, I re-ran the web server load test (`ab`).

| Metric | Before Optimization | After Optimization | Improvement |
| :--- | :--- | :--- | :--- |
| **Requests Per Second** | 2406.77 | 3935.78 | **~+29% Throughput** |
| **Time Per Request** | 0.4155 ms | 0.254 ms | **Faster Response** |

<img width="1092" height="962" alt="image" src="https://github.com/user-attachments/assets/08f995fe-56a5-4316-a901-b9723bce606f" />

**ApacheBench results showing higher Requests Per Second after tuning.**

## 6. Learning Reflection
This phase demonstrated the tangible impact of default configurations on system performance. Out-of-the-box settings are often generic; tuning them for the specific workload, e.g., a headless web server, yielded a measurable performance increase. I learned that optimization is not just about raw speed—lowering swappiness was a strategic decision to trade a small amount of RAM availability for significantly reduced disk wear and latency, illustrating a professional understanding of **OS resource management trade-offs**.

---
[← Previous: Week 5](./week5.md) | [Return to Home](./index.md) | [Next: Week 7 →](./week7.md)
