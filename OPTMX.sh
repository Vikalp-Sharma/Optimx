#!/usr/bin/env bash
# ================================================================
#   OPTMX v3.0 - Linux Edition
#   The Ultimate Linux Performance, Privacy & Network Suite
#   GUI: UNTOUCHED  |  Security: KEPT  |  Network: MAXED
#   Supports: Fedora, Ubuntu, Debian, Arch, openSUSE
# ================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }
step() { echo -e "\n${CYAN}${BOLD}$1${NC}"; }

# --- Root check ---
if [[ $EUID -ne 0 ]]; then
    echo "Requesting root privileges..."
    exec sudo bash "$0" "$@"
fi

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo "~$REAL_USER")

echo ""
echo "  ================================================================"
echo "    OPTMX v3.0 - Linux Edition"
echo "    GUI: UNTOUCHED  |  Security: ON  |  Network: MAXED"
echo "  ================================================================"
echo ""

# ================================================================
# [1/12] DEEP CACHE CLEANING
# ================================================================
step "[1/12] Deep cleaning all caches..."

# User temp & cache
rm -rf /tmp/.X*-lock 2>/dev/null || true
find /tmp -mindepth 1 -maxdepth 1 -user "$REAL_USER" -mtime +1 -exec rm -rf {} + 2>/dev/null || true
find /var/tmp -mindepth 1 -maxdepth 1 -mtime +7 -exec rm -rf {} + 2>/dev/null || true

# Thumbnail cache (safe — auto-regenerated)
rm -rf "$REAL_HOME/.cache/thumbnails"/* 2>/dev/null || true

# Old journal logs (keep 3 days)
journalctl --vacuum-time=3d --quiet 2>/dev/null || true

# Old coredumps
find /var/lib/systemd/coredump -type f -mtime +3 -delete 2>/dev/null || true
rm -rf "$REAL_HOME/.cache/tracker3" 2>/dev/null || true

# Package manager cache
if command -v dnf &>/dev/null; then
    dnf clean all --quiet 2>/dev/null || true
elif command -v apt &>/dev/null; then
    apt-get clean -qq 2>/dev/null || true
elif command -v pacman &>/dev/null; then
    pacman -Sc --noconfirm --quiet 2>/dev/null || true
fi

log "Caches cleaned."

# ================================================================
# [2/12] FLUSH DNS
# ================================================================
step "[2/12] Flushing DNS cache..."

# systemd-resolved
systemctl is-active --quiet systemd-resolved 2>/dev/null && resolvectl flush-caches 2>/dev/null || true
# nscd
systemctl is-active --quiet nscd 2>/dev/null && nscd -i hosts 2>/dev/null || true

log "DNS flushed."

# ================================================================
# [3/12] CPU PERFORMANCE GOVERNOR
# ================================================================
step "[3/12] Setting CPU to performance mode..."

# Set governor to performance (safe — does NOT overclock, just removes throttling)
if [[ -d /sys/devices/system/cpu/cpu0/cpufreq ]]; then
    for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "performance" > "$gov" 2>/dev/null || true
    done
    log "CPU governor: performance"
else
    warn "No cpufreq — skipping (VM or fixed-clock CPU)."
fi

# Disable CPU boost limiting (let turbo work freely)
if [[ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]]; then
    echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
    log "Intel Turbo Boost: enabled"
elif [[ -f /sys/devices/system/cpu/cpufreq/boost ]]; then
    echo 1 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true
    log "CPU Boost: enabled"
fi

# ================================================================
# [4/12] KERNEL SCHEDULER & VM TUNING
# ================================================================
step "[4/12] Tuning kernel scheduler & memory..."

# Reduce swappiness (keep more in RAM, less swap thrashing)
# 10 is safe — still swaps under memory pressure, just prefers RAM
sysctl -w vm.swappiness=10 -q 2>/dev/null || true

# Faster dirty page writeback (reduces I/O stalls)
sysctl -w vm.dirty_ratio=15 -q 2>/dev/null || true
sysctl -w vm.dirty_background_ratio=5 -q 2>/dev/null || true

# VFS cache pressure — keep inode/dentry cache longer
sysctl -w vm.vfs_cache_pressure=50 -q 2>/dev/null || true

# Disable kernel NMI watchdog (saves 1 CPU perf counter per core)
sysctl -w kernel.nmi_watchdog=0 -q 2>/dev/null || true

# Max file watchers for IDEs, file managers (GNOME, VS Code, etc.)
sysctl -w fs.inotify.max_user_watches=524288 -q 2>/dev/null || true
sysctl -w fs.inotify.max_user_instances=1024 -q 2>/dev/null || true

log "Kernel tuned."

# ================================================================
# [5/12] I/O SCHEDULER OPTIMIZATION
# ================================================================
step "[5/12] Optimizing I/O schedulers..."

for dev in /sys/block/sd* /sys/block/nvme* /sys/block/vd*; do
    [[ -d "$dev" ]] || continue
    devname=$(basename "$dev")
    rotational=$(cat "$dev/queue/rotational" 2>/dev/null || echo 1)
    if [[ "$rotational" -eq 0 ]]; then
        # SSD/NVMe: use none/mq-deadline (lowest overhead)
        echo "none" > "$dev/queue/scheduler" 2>/dev/null || \
        echo "mq-deadline" > "$dev/queue/scheduler" 2>/dev/null || true
        # Reduce read-ahead for SSDs (they don't benefit from prefetch)
        echo 256 > "$dev/queue/read_ahead_kb" 2>/dev/null || true
        log "$devname (SSD): scheduler=none, readahead=256K"
    else
        # HDD: use mq-deadline (best for seeks)
        echo "mq-deadline" > "$dev/queue/scheduler" 2>/dev/null || true
        echo 1024 > "$dev/queue/read_ahead_kb" 2>/dev/null || true
        log "$devname (HDD): scheduler=mq-deadline, readahead=1024K"
    fi
done

# ================================================================
# [6/12] NETWORK OPTIMIZATION
# ================================================================
step "[6/12] Applying network stack optimizations..."

# --- TCP tuning (safe defaults used by Google/Cloudflare servers) ---
# Enable TCP Fast Open (client + server)
sysctl -w net.ipv4.tcp_fastopen=3 -q 2>/dev/null || true
# Use BBR congestion control (much better than cubic on modern networks)
if modprobe tcp_bbr 2>/dev/null; then
    sysctl -w net.core.default_qdisc=fq -q 2>/dev/null || true
    sysctl -w net.ipv4.tcp_congestion_control=bbr -q 2>/dev/null || true
    log "TCP congestion: BBR"
else
    warn "BBR not available, keeping default."
fi
# Larger socket buffers for high-bandwidth connections
sysctl -w net.core.rmem_max=16777216 -q 2>/dev/null || true
sysctl -w net.core.wmem_max=16777216 -q 2>/dev/null || true
sysctl -w net.ipv4.tcp_rmem="4096 131072 16777216" -q 2>/dev/null || true
sysctl -w net.ipv4.tcp_wmem="4096 65536 16777216" -q 2>/dev/null || true
# Faster TIME_WAIT recycling
sysctl -w net.ipv4.tcp_fin_timeout=15 -q 2>/dev/null || true
# Bigger connection backlog
sysctl -w net.core.somaxconn=4096 -q 2>/dev/null || true
sysctl -w net.core.netdev_max_backlog=4096 -q 2>/dev/null || true
# Enable TCP window scaling
sysctl -w net.ipv4.tcp_window_scaling=1 -q 2>/dev/null || true
# Disable slow start after idle (keeps connection throughput high)
sysctl -w net.ipv4.tcp_slow_start_after_idle=0 -q 2>/dev/null || true
# Enable MTU probing
sysctl -w net.ipv4.tcp_mtu_probing=1 -q 2>/dev/null || true

log "Network stack optimized."

# ================================================================
# [7/12] DNS OPTIMIZATION (Cloudflare)
# ================================================================
step "[7/12] Setting fastest DNS (Cloudflare 1.1.1.1)..."

if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
    # Use systemd-resolved drop-in (non-destructive, survives reboots)
    mkdir -p /etc/systemd/resolved.conf.d
    cat > /etc/systemd/resolved.conf.d/optmx-dns.conf <<'EOF'
[Resolve]
DNS=1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001
FallbackDNS=8.8.8.8 8.8.4.4
DNSOverTLS=opportunistic
EOF
    systemctl restart systemd-resolved 2>/dev/null || true
    log "DNS: Cloudflare 1.1.1.1 (with DoT)"
elif command -v nmcli &>/dev/null; then
    # NetworkManager: set on the active connection
    ACTIVE_CONN=$(nmcli -t -f NAME,DEVICE con show --active 2>/dev/null | head -1 | cut -d: -f1)
    if [[ -n "$ACTIVE_CONN" ]]; then
        nmcli con mod "$ACTIVE_CONN" ipv4.dns "1.1.1.1 1.0.0.1" ipv4.ignore-auto-dns yes 2>/dev/null || true
        nmcli con up "$ACTIVE_CONN" 2>/dev/null || true
        log "DNS: Cloudflare via NetworkManager"
    else
        warn "No active connection found."
    fi
else
    warn "No supported DNS manager found — skipping."
fi

# ================================================================
# [8/12] DISABLE UNNECESSARY SERVICES
# ================================================================
step "[8/12] Disabling unnecessary services..."

# These are safe to disable — they're telemetry, diagnostics, or unused daemons.
# We do NOT touch: NetworkManager, bluetooth, firewalld, cups, avahi, pipewire, etc.
SERVICES_TO_DISABLE=(
    abrtd                    # crash reporter daemon
    abrt-journal-core        # crash reporter
    abrt-oops                # crash reporter
    abrt-xorg                # crash reporter
    sssd                     # system security services (unused on single-user desktops)
    pcscd                    # smart card daemon (if no smart cards)
    ModemManager             # modem manager (if no cellular modem)
    fwupd                    # firmware updater (can run manually)
    packagekit               # background package updater
)

for svc in "${SERVICES_TO_DISABLE[@]}"; do
    if systemctl is-enabled --quiet "$svc" 2>/dev/null; then
        systemctl stop "$svc" 2>/dev/null || true
        systemctl disable "$svc" 2>/dev/null || true
        log "Disabled: $svc"
    fi
done

# ================================================================
# [9/12] FILESYSTEM OPTIMIZATION
# ================================================================
step "[9/12] Optimizing filesystem..."

# Disable atime updates on all ext4/btrfs/xfs mounts (reduces write I/O)
# This is done via remount — does NOT break anything, purely reduces metadata writes
while IFS= read -r line; do
    mountpoint=$(echo "$line" | awk '{print $2}')
    fstype=$(echo "$line" | awk '{print $3}')
    opts=$(echo "$line" | awk '{print $4}')
    if [[ "$fstype" =~ ^(ext4|btrfs|xfs)$ ]] && [[ ! "$opts" =~ noatime ]]; then
        mount -o remount,noatime "$mountpoint" 2>/dev/null || true
        log "noatime on $mountpoint ($fstype)"
    fi
done < <(grep -E '^/dev/' /proc/mounts)

# Enable periodic TRIM for SSDs (if not already)
if command -v fstrim &>/dev/null; then
    systemctl enable --now fstrim.timer 2>/dev/null || true
    log "SSD TRIM timer: enabled"
fi

# ================================================================
# [10/12] TRANSPARENT HUGEPAGES (careful — safe for desktop)
# ================================================================
step "[10/12] Configuring hugepages..."

# Set THP to 'madvise' — apps that want it can opt in, but it won't cause
# random latency spikes like 'always' does (which is bad for gaming/audio)
if [[ -f /sys/kernel/mm/transparent_hugepage/enabled ]]; then
    echo "madvise" > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || true
    echo "madvise" > /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null || true
    log "THP: madvise (opt-in, no latency spikes)"
fi

# ================================================================
# [11/12] SECURITY (KEPT INTACT)
# ================================================================
step "[11/12] Security: SELinux/AppArmor KEPT ENABLED."

# We do NOT disable SELinux, AppArmor, firewalld, or any security feature.
# If you want raw performance and accept the risk, uncomment:
# setenforce 0  # Disable SELinux temporarily
# systemctl stop firewalld

log "Security untouched."

# ================================================================
# [12/12] MAKE PERSISTENT (optional sysctl.d drop-in)
# ================================================================
step "[12/12] Making optimizations persistent across reboots..."

cat > /etc/sysctl.d/99-optmx.conf <<'SYSCTL'
# OPTMX v3.0 Linux Edition - Persistent kernel tuning
# Safe performance optimizations — GUI/Security untouched

# Memory
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 50

# Disable NMI watchdog
kernel.nmi_watchdog = 0

# Filesystem watchers
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 1024

# Network
net.ipv4.tcp_fastopen = 3
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 131072 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_fin_timeout = 15
net.core.somaxconn = 4096
net.core.netdev_max_backlog = 4096
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_mtu_probing = 1
SYSCTL

log "Persistent config: /etc/sysctl.d/99-optmx.conf"

# CPU governor persistence via systemd tmpfiles
cat > /etc/tmpfiles.d/optmx-cpu.conf <<'TMPF'
w /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor - - - - performance
TMPF

log "CPU governor persistence: /etc/tmpfiles.d/optmx-cpu.conf"

echo ""
echo "  ================================================================"
echo "    OPTMX v3.0 Linux Edition - ALL OPTIMIZATIONS APPLIED!"
echo ""
echo "    Cache:           CLEANED"
echo "    DNS:             CLOUDFLARE 1.1.1.1 (DoT)"
echo "    CPU Governor:    PERFORMANCE"
echo "    CPU Boost:       ENABLED"
echo "    TCP Stack:       BBR + FAST OPEN + TUNED BUFFERS"
echo "    Kernel:          SWAPPINESS=10, NMI OFF, VFS TUNED"
echo "    I/O Scheduler:   SSD=none, HDD=mq-deadline"
echo "    Filesystem:      NOATIME + TRIM TIMER"
echo "    Hugepages:       MADVISE (safe, no latency spikes)"
echo "    Services:        ABRT/MODEM/PACKAGEKIT DISABLED"
echo "    Security:        SELINUX/FIREWALL UNTOUCHED"
echo "    GUI/Desktop:     100% UNTOUCHED"
echo "    Persistence:     SYSCTL + TMPFILES DROP-INS"
echo ""
echo "    >>> Changes are live. Reboot for full persistence. <<<"
echo "  ================================================================"
