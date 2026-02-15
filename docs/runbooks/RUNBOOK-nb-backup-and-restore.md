# RUNBOOK: nb backup & restore (t480, local bare repo)

## Purpose

Protect the `~/.nb/t480` notebook (T480 control-plane decisions, logs, and notes) by backing it up into a local bare Git repository, and provide a clear restore procedure for rebuilding `~/.nb/t480` on this host.

This is a **T480-only** procedure. Remote backups (e.g., srv-m1m Forgejo) will be addressed in a later ADR and runbook once the control-plane workflows are stable.

## Scope

- Applies to: T480 notebook at `~/.nb/t480`.
- Does not cover: other nb notebooks (`srv-m1m`, `linux-pro`, `toolkit`) or secrets handling.
- Backup target: local bare Git repo at `~/Sync/nb-backups/t480.git`.

## Prerequisites

- T480 is booted and you have shell + nb access.
- Git is installed and configured with your user name/email.
- Directory `~/Sync/nb-backups/` exists or can be created.
- `~/.nb/t480` is already in use by nb and contains notes.

Verify:

```bash
nb use t480
ls -la ~/.nb/t480
git --version
```

If `~/Sync/nb-backups/` does not exist:

```bash
mkdir -p ~/Sync/nb-backups
```

---

## Initial Setup (one-time bare repo creation)

Run this section once to create the backup repo and perform the first backup.

### 1. Create bare repo for t480 nb backups

```bash
cd ~/Sync/nb-backups

# Create a bare Git repository to hold the nb notebook history
git init --bare t480.git
```

This repo will store the full history of `~/.nb/t480`, but not act as a working tree.

### 2. Initialize a local Git repo for ~/.nb/t480 (if not already Git-backed)

Check if nb already initialized Git:

```bash
cd ~/.nb/t480
git rev-parse --is-inside-work-tree 2>/dev/null && echo "Already a Git repo"
```

If not a Git repo, initialize:

```bash
cd ~/.nb/t480
git init

# Optional but recommended: set a simple .gitignore if needed
# touch .gitignore
```

Configure minimal identity (if not global):

```bash
git config user.name "ch1ch0"
git config user.email "you@example.com"
```

### 3. Add remote pointing to bare backup repo

```bash
cd ~/.nb/t480

# Name the remote "backup-t480-local"
git remote add backup-t480-local ~/Sync/nb-backups/t480.git
```

Verify:

```bash
git remote -v
# Expect: backup-t480-local  /home/ch1ch0/Sync/nb-backups/t480.git (fetch/push)
```

### 4. Perform initial backup

```bash
cd ~/.nb/t480

# Stage everything; rely on nb’s own auto-commits plus this snapshot
git add -A

git commit -m "backup: initial snapshot of nb t480 notebook"

# Push to the bare backup repo
git push backup-t480-local main || git push backup-t480-local master
```

Use `main` for new repos; if Git defaulted to `master`, adjust accordingly.

---

## Regular Backup Procedure (manual, v1)

Use this procedure whenever you want to capture the current state of `~/.nb/t480` into the backup repo.

### 1. Review current nb state (optional)

```bash
nb use t480
nb t480: ls --sort --reverse --limit 5
```

### 2. Commit notebook changes locally

```bash
cd ~/.nb/t480

git status

# Stage new/changed files
git add -A

# Commit with a descriptive message
git commit -m "backup: nb t480 notebook snapshot $(date +%Y-%m-%d)"
```

If there are no changes, Git will tell you; backup push is then optional.

### 3. Push to local bare backup repo

```bash
cd ~/.nb/t480

git push backup-t480-local main || git push backup-t480-local master
```

### 4. Verify backup

```bash
cd ~/Sync/nb-backups/t480.git

# Show recent commits in the bare repo
git log --oneline --decorate --graph --all | head -10
```

---

## Restore Procedure (manual, v1)

Use this procedure to restore `~/.nb/t480` on the same T480 after data loss or on a fresh rebuild, using the local bare backup repo.

### 1. Ensure nb and Git are installed

On the rebuilt T480:

```bash
# Verify Git
git --version

# Verify nb (using your usual install method)
nb --version
```

### 2. Prepare ~/.nb directory

```bash
mkdir -p ~/.nb
cd ~/.nb

# If ~/.nb/t480 already exists and is corrupted, move it aside
[ -d t480 ] && mv t480 t480.corrupted.$(date +%Y%m%d-%H%M%S)
```

### 3. Clone from bare backup into ~/.nb/t480

From `~/.nb`:

```bash
cd ~/.nb

# Clone the bare backup repo into t480
git clone ~/Sync/nb-backups/t480.git t480
```

This recreates the working tree at `~/.nb/t480` with all tracked nb files.

### 4. Rebuild nb index and verify

```bash
# Rebuild nb’s internal index
cd ~
nb use t480
nb index rebuild

# Verify notes are visible
nb t480:
nb t480: ls --sort --reverse --limit 5
```

At this point, `~/.nb/t480` should be fully restored.

---

## Notes & Caveats

- This runbook assumes the backup repo (`~/Sync/nb-backups/t480.git`) is stored on a **reliable local or synced location** (e.g., Syncthing). Extending this to srv-m1m or Forgejo requires a separate ADR and runbook.
- Avoid storing highly sensitive secrets in nb unless:
  - They are encrypted notes, or
  - You are fully comfortable with where the backup repo is stored and replicated.
- Once you introduce a Forgejo remote on srv-m1m:
  - Add another remote (e.g., `backup-t480-srv-m1m`) and update this runbook with an additional push target, guarded by an ADR that covers access control.

---

## References

- ADR: nb backup strategy for t480 (`adr_nb_backup_strategy_t480.md` in nb).
- ADR-001: T480 golden-state Ansible structure (this repo).
- ADR-002: T480 golden-state baseline v1.0 applied (this repo).
- T480 MOC: `moc_t480.md` (in nb).

