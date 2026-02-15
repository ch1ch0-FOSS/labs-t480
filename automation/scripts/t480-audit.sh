#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

TS="$(date +%F-%H%M%S)"
HOSTNAME="$(hostname)"
OUT="t480-audit-${HOSTNAME}-${TS}.log"

# Send all stdout+stderr to one log file, while still showing on screen
exec > >(tee -a "${OUT}") 2>&1

echo "### AUDIT_METADATA"
echo "host: ${HOSTNAME}"
echo "timestamp: ${TS}"
echo "tool: t480-audit.sh"
echo "version: 1"
echo

section() {
  printf '\n### AUDIT_SECTION_START %s\n' "$1"
}

section_end() {
  printf '### AUDIT_SECTION_END %s\n' "$1"
}

############################################################
# SYSTEM
############################################################
section "system"

echo "## system.uname"
uname -a

echo
echo "## system.os_release"
cat /etc/os-release

echo
echo "## system.uptime"
uptime -p

echo
echo "## system.cpu"
lscpu

echo
echo "## system.memory"
free -h

echo
echo "## system.hostnamectl"
hostnamectl

echo
echo "## system.logins"
who
last -x | head -n 200

section_end "system"

############################################################
# HARDWARE / DMI
############################################################
section "hardware"

# Optional: uncomment if you install lshw (sudo dnf install lshw)
# echo
# echo "## hardware.lshw"
# sudo lshw -sanitize

echo
echo "## hardware.pci"
lspci -nnvv

echo
echo "## hardware.usb"
lsusb -vv 2>/dev/null || true

echo
echo "## hardware.block_devices"
lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,MOUNTPOINT,FSTYPE,UUID

echo
echo "## hardware.dmidecode.system"
sudo dmidecode -t system

echo
echo "## hardware.dmidecode.bios"
sudo dmidecode -t bios

echo
echo "## hardware.dmidecode.chassis"
sudo dmidecode -t chassis

echo
echo "## hardware.dmidecode.memory"
sudo dmidecode -t memory

echo
echo "## hardware.dmidecode.processor"
sudo dmidecode -t processor

section_end "hardware"

############################################################
# STORAGE
############################################################
section "storage"

echo "## storage.lsblk_f"
lsblk -f

echo
echo "## storage.partitions"
sudo fdisk -l

echo
echo "## storage.fstab"
cat /etc/fstab

echo
echo "## storage.mounts"
mount

echo
echo "## storage.smart"
for d in /dev/sd? /dev/nvme?n1 2>/dev/null; do
  echo "--- SMART for ${d} ---"
  sudo smartctl -a "$d" || true
done

section_end "storage"

############################################################
# POWER / SENSORS
############################################################
section "power"

echo "## power.acpi"
acpi -V 2>/dev/null || true

echo
echo "## power.tlp"
tlp-stat -s -b -c -t -r 2>/dev/null || true

echo
echo "## power.sensors"
# Non-interactive: only read sensors (no probing)
sensors || true

section_end "power"

############################################################
# NETWORK
############################################################
section "network"

echo "## network.ip_addr"
ip addr show

echo
echo "## network.ip_route"
ip route show

echo
echo "## network.link_stats"
ip -s link

echo
echo "## network.nmcli_devices"
nmcli dev show 2>/dev/null || true

echo
echo "## network.nmcli_connections"
nmcli con show 2>/dev/null || true

echo
echo "## network.rfkill"
rfkill list 2>/dev/null || true

echo
echo "## network.iwconfig"
iwconfig 2>/dev/null || true

section_end "network"

############################################################
# KERNEL / BOOT / SERVICES
############################################################
section "kernel_services"

echo "## kernel.cmdline"
cat /proc/cmdline

echo
echo "## kernel.modules"
lsmod

echo
echo "## kernel.journal.current_boot"
journalctl -b -0

echo
echo "## kernel.journal.previous_boot"
journalctl -b -1 2>/dev/null || true

echo
echo "## services.running"
systemctl list-units --type=service --state=running

echo
echo "## services.unit_files"
systemctl list-unit-files --type=service

echo
echo "## services.failed"
systemctl --failed

section_end "kernel_services"

############################################################
# PACKAGES / SECURITY
############################################################
section "packages_security"

echo "## packages.dnf_installed"
sudo dnf list installed

echo
echo "## security.sockets"
ss -pltun

echo
echo "## security.iptables"
sudo iptables-save 2>/dev/null || true

echo
echo "## security.nftables"
sudo nft list ruleset 2>/dev/null || true

echo
echo "## security.selinux"
getenforce 2>/dev/null || true

echo
echo "## security.identity"
id

echo
echo "## security.sudo_l"
sudo -l 2>/dev/null || true

echo
echo "## security.groups"
getent group

section_end "packages_security"

echo
echo "### AUDIT_COMPLETE $(date +%F-%H%M%S)"
