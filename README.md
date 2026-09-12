# OPTMX 🚀

```text
                ██████╗ ██████╗ ████████╗██╗███╗   ███╗██╗  ██╗
               ██╔═══██╗██╔══██╗╚══██╔══╝██║████╗ ████║╚██╗██╔╝
               ██║   ██║██████╔╝   ██║   ██║██╔████╔██║ ╚███╔╝
               ██║   ██║██╔═══╝    ██║   ██║██║╚██╔╝██║ ██╔██╗
               ╚██████╔╝██║        ██║   ██║██║ ╚═╝ ██║██╔╝ ██╗
                ╚═════╝ ╚═╝        ╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝

╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║                     ⚡ O P T I M I Z E   E V E R Y T H I N G ⚡            ║
║                                                                            ║
║          Ultimate Windows 11 Performance • Privacy • Network Tool          ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
```

**The Ultimate Windows 11 Performance, Privacy, and Network Optimizer.**

---

## ⚡ What is OPTMX?
OPTMX is a heavily engineered, fully automated batch script designed to extract the maximum possible performance out of Windows 11 without compromising essential system features. 

Unlike other "debloat" scripts that break your system, OPTMX is surgically precise:
- **🎨 Visuals:** 100% untouched. Your animations, transparency, and UI stay beautiful.
- **🛡️ Security:** 100% kept intact. Core Isolation (VBS/HVCI) remains enabled to protect you.
- **📍 Location & Essentials:** Unchanged. Your location services, Bluetooth, and Wi-Fi work perfectly.
- **🤖 Copilot:** Stopped at startup, but NOT uninstalled. It's there when you need it, gone when you don't.

---

## 🔥 Features Breakdown

### 1. 🗑️ Deep Cache & Junk Annihilation
Wipes out unnecessary temporary files, Windows Update caches, old thumbnails, Windows Error Reporting logs, and crash dumps that clog up your C: drive.

### 2. 🔌 Ultimate Power Profile
Forces Windows into the hidden **Ultimate Performance** power plan, disables CPU throttling, disables USB sleep (so your devices never disconnect during games), and turns off hibernation to free up gigabytes of RAM space on your SSD.

### 3. 🧠 CPU Scheduler Tuning
Changes the core `Win32PrioritySeparation` registry key to aggressively prioritize the foreground app (your game or active window) with a 3:1 ratio over background tasks. Also raises the system timer clock rate to `10000` for maximum precision.

### 4. 🎮 GPU Maximization
Forces Hardware-Accelerated GPU Scheduling (HAGS), kills Game DVR/Game Bar background recording, and disables Fullscreen Optimizations to eliminate input lag.

### 5. 🌐 7-Layer Network Stack (Zero Latency)
The most advanced TCP/IP tuning available:
- Disables Nagle's Algorithm on **all** active network interfaces (instant packet sending).
- Enables TCP Fast Open and Receive Side Scaling (RSS).
- Disables 12-byte TCP timestamps and Delivery Optimization (P2P Windows Updates).
- Shrinks `TIME_WAIT` socket recycling to 30s and expands max user ports.
- Hardcodes **Cloudflare DNS (1.1.1.1)** globally for blistering fast web lookups.

### 6. 🛑 Auto-Startup Blockers
Kills heavy background hogs from starting with your PC:
- **Microsoft Edge** (Pre-launch, background extensions, and startup boost killed).
- **Edge WebView2** (Prevents silent background rendering).
- **WhatsApp** & **Copilot** (Removed from auto-run).

### 7. 🕵️ Telemetry Lockdown
Blocks Microsoft's data collection via registry policies. Stops Advertising IDs, activity feeds, tailored experiences, and location tracking (while keeping the master location switch working for your apps). Kills 12 useless background services including `SysMain` (Superfetch) and `DiagTrack`.

### 8. 🔄 Permanent Auto-Run
OPTMX makes itself permanent. When you run it once, it securely copies itself to `System32` and creates a **Highest Privilege Scheduled Task** to run silently in the background on every single boot. Your PC stays optimized forever.

---

## 🛠️ Usage Instructions

1. Locate `OPTMX.bat`.
2. **Double-click** it. (It automatically asks for Administrator rights).
3. Wait for the terminal to display the success message.
4. **Reboot your PC.**

---
*Created strictly for personal, non-commercial use. See LICENSE.txt for legal details.*
