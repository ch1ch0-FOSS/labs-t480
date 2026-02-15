#!/usr/bin/env bash
# nb-promote.sh - Promote nb artifacts to Git repos

set -euo pipefail

T480_REPO="$HOME/projects/labs/t480"
SRVMIM_REPO="$HOME/projects/labs/srv-m1m"

usage() {
    cat <<EOF
Usage: nb-promote.sh <notebook>:<filename-or-id>

Examples:
  nb-promote.sh t480:6
  nb-promote.sh t480:adr_golden_state_ansible.md
EOF
    exit 1
}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

# --- Parse arguments ---
[[ $# -eq 1 ]] || usage
SELECTOR="$1"

NOTEBOOK="${SELECTOR%%:*}"
ARTIFACT="${SELECTOR#*:}"
[[ "$NOTEBOOK" != "$SELECTOR" ]] || die "Format: notebook:artifact"

# --- Determine repo ---
case "$NOTEBOOK" in
    t480) REPO="$T480_REPO" ;;
    srv-m1m) REPO="$SRVMIM_REPO" ;;
    *) die "Unsupported notebook: $NOTEBOOK" ;;
esac
[[ -d "$REPO" ]] || die "Repo not found: $REPO"

# --- Construct direct path (works with nb directory structure) ---
NB_DIR="$HOME/.nb/$NOTEBOOK"
[[ -d "$NB_DIR" ]] || die "Notebook not found: $NB_DIR"

# If artifact is numeric (ID), resolve filename via nb
if [[ "$ARTIFACT" =~ ^[0-9]+$ ]]; then
    # Use nb to get the filename for this ID
    FILENAME=$(nb "$SELECTOR" --filename 2>/dev/null) || \
        die "Failed to resolve ID: $ARTIFACT in $NOTEBOOK"
    NB_PATH="$NB_DIR/$FILENAME"
else
    # Assume artifact is already a filename
    NB_PATH="$NB_DIR/$ARTIFACT"
fi

[[ -f "$NB_PATH" ]] || die "File not found: $NB_PATH"

NB_FILENAME=$(basename "$NB_PATH")

echo "✓ Resolved: $NB_FILENAME"

# --- Validate nb naming convention ---
if [[ ! "$NB_FILENAME" =~ ^(adr|runbook|incident|log)_ ]]; then
    die "Invalid nb convention: $NB_FILENAME
Expected format: adr_*.md, runbook_*.md, incident_*.md, log_*.md"
fi

# --- Determine type and destination ---
TYPE="${NB_FILENAME%%_*}"
TYPE="${TYPE^^}"

case "$TYPE" in
    ADR)
        DEST_DIR="$REPO/ADR"
        PREFIX="ADR-"
        ;;
    RUNBOOK)
        DEST_DIR="$REPO/runbooks"
        PREFIX="RUNBOOK-"
        ;;
    INCIDENT)
        DEST_DIR="$REPO/incidents"
        PREFIX="INCIDENT-"
        ;;
    LOG)
        echo "WARN: Logs generally not promoted. Continue? (y/N)"
        read -r CONFIRM
        [[ "$CONFIRM" =~ ^[Yy]$ ]] || exit 0
        DEST_DIR="$REPO/docs"
        PREFIX="LOG-"
        ;;
    *)
        die "Unknown type: $TYPE"
        ;;
esac

mkdir -p "$DEST_DIR"

# --- Generate destination filename ---
BASE_NAME="${NB_FILENAME#*_}"
BASE_NAME="${BASE_NAME%.md}"
BASE_NAME="${BASE_NAME//_/-}"

if [[ "$TYPE" == "ADR" ]]; then
    EXISTING=$(find "$DEST_DIR" -name 'ADR-*.md' 2>/dev/null | wc -l)
    NEXT_NUM=$((EXISTING + 1))
    printf "ADR sequence number [%03d]: " "$NEXT_NUM"
    read -r ADR_NUM
    ADR_NUM="${ADR_NUM:-$NEXT_NUM}"
    DEST_FILENAME="ADR-$(printf '%03d' "$ADR_NUM")-${BASE_NAME}.md"
elif [[ "$TYPE" == "INCIDENT" ]]; then
    if [[ "$NB_FILENAME" =~ ([0-9]{8}) ]]; then
        DATE_STAMP="${BASH_REMATCH[1]}"
        DATE="${DATE_STAMP:0:4}-${DATE_STAMP:4:2}-${DATE_STAMP:6:2}"
    else
        DATE=$(date +%Y-%m-%d)
    fi
    DEST_FILENAME="INCIDENT-${DATE}-${BASE_NAME}.md"
else
    DEST_FILENAME="${PREFIX}${BASE_NAME}.md"
fi

DEST_PATH="$DEST_DIR/$DEST_FILENAME"

# --- Summary & confirm ---
echo ""
echo "=== Promotion Summary ==="
echo "Type:        $TYPE"
echo "Source:      $NB_PATH"
echo "Destination: $DEST_PATH"
echo ""
echo "Proceed? (y/N)"
read -r CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# --- Git workflow ---
cd "$REPO"

if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    die "Repo has uncommitted changes. Commit or stash first."
fi

BRANCH_NAME="nb-promote/$(echo "$BASE_NAME" | head -c 40)"
git checkout -b "$BRANCH_NAME"

cp "$NB_PATH" "$DEST_PATH"
echo "✓ Copied: $DEST_PATH"

git add "$DEST_PATH"
COMMIT_MSG="docs: promote $TYPE from nb - $BASE_NAME"
git commit -m "$COMMIT_MSG"
COMMIT_HASH=$(git rev-parse --short HEAD)

echo ""
echo "=== Promotion Complete ==="
echo "Branch:      $BRANCH_NAME"
echo "Commit:      $COMMIT_HASH"
echo ""
echo "Next steps:"
echo "  1. Review:  vim $DEST_PATH"
echo "  2. Merge:   git checkout main && git merge $BRANCH_NAME"
echo "  3. Clean:   git branch -d $BRANCH_NAME"
echo "  4. Mark nb: nb $SELECTOR --edit"

exit 0

