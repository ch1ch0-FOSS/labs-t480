#!/usr/bin/env bash
# T480 baseline v1.0 validation script

set -euo pipefail

echo "[INFO] Validating T480 golden state v1.0..."

failures=0

check_pkg() {
  local pkg="$1"
  if rpm -q "$pkg" >/dev/null 2>&1; then
    echo "[OK] package: $pkg"
  else
    echo "[FAIL] package missing: $pkg"
    failures=$((failures+1))
  fi
}

check_bin() {
  local bin="$1"
  if command -v "$bin" >/dev/null 2>&1; then
    echo "[OK] binary: $bin ($(command -v "$bin"))"
  else
    echo "[FAIL] binary missing on PATH: $bin"
    failures=$((failures+1))
  fi
}

check_service_active() {
  local svc="$1"
  if systemctl is-active --quiet "$svc"; then
    echo "[OK] service active: $svc"
  else
    echo "[FAIL] service not active: $svc"
    failures=$((failures+1))
  fi
}

echo "== Packages =="

# Core
for p in bash coreutils util-linux grep sed gawk findutils iproute iputils \
         NetworkManager dnf-plugins-core openssh-clients openssh-server \
         libselinux-utils policycoreutils policycoreutils-python-utils setools-console; do
  check_pkg "$p"
done

# DNF: accept dnf or dnf5 as provider of /usr/bin/dnf
if rpm -q dnf >/dev/null 2>&1 || rpm -q dnf5 >/dev/null 2>&1; then
  echo "[OK] package: dnf/dnf5"
else
  echo "[FAIL] package missing: dnf (or dnf5)"
  failures=$((failures+1))
fi

# Vi-centric
for p in tmux foot vimb w3m ddgr wl-clipboard; do
  check_pkg "$p"
done

# Vim: accept vim or vim-enhanced
if rpm -q vim >/dev/null 2>&1 || rpm -q vim-enhanced >/dev/null 2>&1; then
  echo "[OK] package: vim/vim-enhanced"
else
  echo "[FAIL] package missing: vim (or vim-enhanced)"
  failures=$((failures+1))
fi

# Infra
for p in git stow ansible-core chrony sysstat lvm2 xfsprogs tcpdump nmap nmap-ncat podman; do
  check_pkg "$p"
done

# VM
for p in qemu-kvm libvirt libvirt-daemon libvirt-daemon-config-network virt-install; do
  check_pkg "$p"
done

# Sync / misc (except wget — handled specially)
for p in syncthing tailscale rsync tar xz gzip bzip2 curl; do
  check_pkg "$p"
done

# Wget: accept wget or wget2-wget as provider of /usr/bin/wget
if rpm -q wget >/dev/null 2>&1 || rpm -q wget2-wget >/dev/null 2>&1; then
  echo "[OK] package: wget/wget2-wget"
else
  echo "[FAIL] package missing: wget (or wget2-wget)"
  failures=$((failures+1))
fi

echo
echo "== Binaries on PATH =="

for b in vim tmux foot vimb w3m ddgr git stow ansible-playbook chronyc sar \
         lvm pvcreate vgcreate lvcreate xfs_repair tcpdump nmap ncat podman \
         syncthing tailscale nb; do
  check_bin "$b"
done

echo
echo "== Services =="

for s in firewalld sshd chronyd tailscaled; do
  check_service_active "$s"
done

echo
if [ "$failures" -eq 0 ]; then
  echo "[INFO] Baseline validation PASSED."
  exit 0
else
  echo "[INFO] Baseline validation FAILED with $failures issues."
  exit 1
fi
