#!/usr/bin/env bash

set -o nounset -o pipefail

LOG="${1:-}"

if [[ -z "${LOG}" ]]; then
  echo "Usage: $0 PATH/TO/t480-audit-*.log" >&2
  exit 1
fi

HOST="$(grep '^host:' "${LOG}" | head -n1 | awk '{print $2}')"
TS="$(grep '^timestamp:' "${LOG}" | head -n1 | awk '{print $2}')"

OS="$(awk '/## system.os_release/{flag=1;next}/^## /{flag=0}flag' "${LOG}" \
  | grep '^PRETTY_NAME=' | head -n1 | cut -d= -f2- | tr -d '"' )"

KERNEL_LINE="$(awk '/## system.uname/{getline;print;exit}' "${LOG}")"
KERNEL="$(printf '%s\n' "${KERNEL_LINE}" | awk '{print $3}')"
ARCH="$(printf '%s\n' "${KERNEL_LINE}" | awk '{print $13}')"

UPTIME="$(awk '/## system.uptime/{getline;print;exit}' "${LOG}")"

CPU_MODEL="$(awk -F: '/^Model name:/ {print $2; exit}' "${LOG}" | sed 's/^ *//')"
CPU_CORES="$(awk -F: '/^Core\(s\) per socket:/ {gsub(/ /,"",$2); print $2; exit}' "${LOG}" 2>/dev/null || echo '?')"
CPU_THREADS="$(awk -F: '/^CPU\(s\):/ {gsub(/ /,"",$2); print $2; exit}' "${LOG}" 2>/dev/null || echo '?')"

MEM_TOTAL="$(awk '/^Mem:/ {print $2; exit}' "${LOG}")"

VENDOR="$(awk -F: '/^\s*Manufacturer:/ {print $2; exit}' "${LOG}" | sed 's/^ *//')"
PRODUCT="$(awk -F: '/^\s*Product Name:/ {print $2; exit}' "${LOG}" | sed 's/^ *//')"
SKU="$(awk -F: '/^\s*SKU Number:/ {print $2; exit}' "${LOG}" | sed 's/^ *//')"

BIOS_VER="$(awk -F: '/^\s*Version:/ {print $2; exit}' "${LOG}" | sed 's/^ *//')"
BIOS_DATE="$(awk -F: '/^\s*Release Date:/ {print $2; exit}' "${LOG}" | sed 's/^ *//')"

GPU_LINE="$(awk '/## hardware.pci/{flag=1} flag && /VGA compatible controller/ {print; exit}' "${LOG}")"
GPU_MODEL="$(printf '%s\n' "${GPU_LINE}" \
  | cut -d']' -f2- \
  | sed 's/^(rev.*//; s/ *(prog.*//; s/^ *//')"

# Extract storage info from lsblk_f section using simpler parsing
LSBLK_SECTION="$(awk '/## storage.lsblk_f/{flag=1;next}/^## /{flag=0}flag' "${LOG}")"

# Extract root device and info from the root mount line
ROOT_INFO="$(printf '%s\n' "${LSBLK_SECTION}" | grep -E '^\S+\s+.*\/$' | head -n1)"
ROOT_DEV="$(printf '%s\n' "${ROOT_INFO}" | awk '{print $1}')"
ROOT_FS_SIZE="$(printf '%s\n' "${ROOT_INFO}" | awk '{print $2}')"
ROOT_FS_TYPE="$(printf '%s\n' "${ROOT_INFO}" | awk '{print $3}')"

# Extract /boot/efi info
EFI_INFO="$(printf '%s\n' "${LSBLK_SECTION}" | grep -E '^\S+\s+.*\/boot\/efi$' | head -n1)"
EFI_DEV="$(printf '%s\n' "${EFI_INFO}" | awk '{print $1}')"
EFI_SIZE="$(printf '%s\n' "${EFI_INFO}" | awk '{print $2}')"
EFI_FSTYPE="$(printf '%s\n' "${EFI_INFO}" | awk '{print $3}')"

# Extract /boot info
BOOT_INFO="$(printf '%s\n' "${LSBLK_SECTION}" | grep -E '^\S+\s+.*\/boot$' | head -n1)"
BOOT_DEV="$(printf '%s\n' "${BOOT_INFO}" | awk '{print $1}')"
BOOT_SIZE="$(printf '%s\n' "${BOOT_INFO}" | awk '{print $2}')"
BOOT_FSTYPE="$(printf '%s\n' "${BOOT_INFO}" | awk '{print $3}')"

SELINUX_RAW="$(awk '/## security.selinux/{getline;print;exit}' "${LOG}" 2>/dev/null || echo 'unknown')"
SELINUX="$(printf '%s\n' "${SELINUX_RAW}" | awk '{print $1}' | tr '[:lower:]' '[:upper:]')"

NFT_PRESENT="$(awk '/## security.nftables/{flag=1;next}/^## /{flag=0}flag' "${LOG}" | wc -l)"
if [[ "${NFT_PRESENT}" -gt 0 ]]; then
  FIREWALL="nftables ruleset present"
else
  FIREWALL="no nftables ruleset in log"
fi

FAILED_SERVICES="$(awk '/## services.failed/{flag=1;next}/^## /{flag=0}flag' "${LOG}" \
  | grep -v '^$' | wc -l)"
if [[ "${FAILED_SERVICES}" -le 1 ]]; then
  FAILED_SERVICES_TEXT="None reported"
else
  FAILED_SERVICES_TEXT="See services.failed section"
fi

OUT_MD="SYSTEM-SPECS.md"

cat > "${OUT_MD}" <<EOF
# System Specs – ${HOST}

Generated from \`${LOG}\` on ${TS}.

## Overview

- Hostname: \`${HOST}\`
- OS: ${OS}
- Kernel: ${KERNEL} (${ARCH})
- Uptime at capture: ${UPTIME}

## Hardware

- Vendor / Model: ${VENDOR} ${PRODUCT} (SKU: ${SKU})
- CPU: ${CPU_MODEL} (${CPU_CORES} cores / ${CPU_THREADS} threads)
- Memory: ${MEM_TOTAL} total
- Graphics: ${GPU_MODEL}
- Firmware: BIOS ${BIOS_VER}, released ${BIOS_DATE}

## Storage Layout

| Device | Size | Mountpoint | FSType |
|--------|------|-----------|--------|
| ${EFI_DEV:-?} | ${EFI_SIZE:-?} | /boot/efi | ${EFI_FSTYPE:-?} |
| ${BOOT_DEV:-?} | ${BOOT_SIZE:-?} | /boot | ${BOOT_FSTYPE:-?} |
| ${ROOT_DEV:-?} | ${ROOT_FS_SIZE:-?} | / | ${ROOT_FS_TYPE:-?} |

## Network

- Interfaces: see \`network.ip_addr\` section in audit log.
- Wireless: see \`hardware.pci\` VGA / network entries for NIC details.

## Security / Services

- SELinux: ${SELINUX}
- Firewall: ${FIREWALL}
- Failed services: ${FAILED_SERVICES_TEXT}
EOF

echo "Wrote ${OUT_MD}"
