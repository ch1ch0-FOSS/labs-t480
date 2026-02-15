#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

INVENTORY="ansible/inventory"
PLAYBOOK="ansible/t480-baseline.yml"

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "ansible-playbook not found. Install ansible-core first."
  exit 1
fi

echo "[INFO] Running T480 baseline in CHECK mode (no changes)..."
ansible-playbook -i "$INVENTORY" "$PLAYBOOK" --check --ask-become-pass

echo
read -r -p "Apply changes for real? [y/N] " ans
case "$ans" in
  y|Y)
    echo "[INFO] Applying T480 baseline (changes will be made)..."
    ansible-playbook -i "$INVENTORY" "$PLAYBOOK" --ask-become-pass
    ;;
  *)
    echo "[INFO] Skipping real apply."
    ;;
esac
