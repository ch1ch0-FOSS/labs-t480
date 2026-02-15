# RUNBOOK: nb to Git Repository Promotion

## Purpose
Promote mature nb artifacts (ADRs, runbooks, incidents) from `~/.nb` notebooks to Git repositories for version control, public documentation, and portfolio presentation.

## Scope
- **Applies to:** t480 and srv-m1m notebooks
- **Destination repos:** 
  - `~/projects/labs/t480`
  - `~/projects/labs/srv-m1m`
- **Artifact types:** ADR, runbook, incident, logs (discouraged)

## Prerequisites
- nb installed and operational on T480
- Git repos initialized and accessible
- `scripts/nb-promote.sh` present and executable
- Clean Git working tree (no uncommitted changes)

## Promotion Criteria

### ADRs
- [ ] Decision finalized (not draft/exploratory)
- [ ] Impact: Affects architecture, tooling, or operational procedures
- [ ] Audience: Would be referenced by another engineer or future-you in 6+ months
- [ ] Completeness: Alternatives considered, rationale documented

### Runbooks
- [ ] Tested: Procedure executed successfully at least once
- [ ] Portable: Another engineer can follow without verbal explanation
- [ ] Stable: Procedure unlikely to change weekly

### Incidents
- [ ] Resolved: Root cause identified, remediation completed
- [ ] Learning value: Contains non-obvious troubleshooting steps
- [ ] Preventable: Led to or should lead to ADR/runbook update

### Logs
- **Generally do not promote** - logs are operational ephemera
- **Exception:** Major milestones (first Ansible run, DR drill results)

## Naming Conventions

### nb naming (source)
```
adr_<descriptive-name>.md
runbook_<descriptive-name>.md
incident_<descriptive-name>.md
log_<descriptive-name>.md
```

### Git naming (destination)
```
ADR/ADR-<NNN>-<name>.md          (sequential numbering)
runbooks/RUNBOOK-<name>.md
incidents/INCIDENT-<YYYY-MM-DD>-<name>.md
docs/LOG-<name>.md               (rare)
```

## Procedure

### 1. Identify candidate for promotion

```bash
# List ADRs in t480 notebook
nb t480: ls adr_

# Review specific artifact
nb t480:show <id-or-filename>
```

**Validation checklist:**
- [ ] Filename follows nb convention (`adr_`, `runbook_`, `incident_`, `daily_`)
- [ ] Artifact meets promotion criteria (see above)
- [ ] Content is complete and accurate

### 2. Ensure clean Git state

```bash
cd ~/projects/labs/t480

# Check for uncommitted changes
git status

# If dirty, commit or stash
git add -A
git commit -m "wip: ongoing work"
```

### 3. Run promotion script

```bash
# Using ID (recommended - avoids filename quoting issues)
~/projects/labs/t480/scripts/nb-promote.sh t480:<id>

# Using filename
~/projects/labs/t480/scripts/nb-promote.sh t480:adr_example_name.md

# For srv-m1m notebook
~/projects/labs/srv-m1m/scripts/nb-promote.sh srv-m1m:<id>
```

**Script prompts:**
1. **ADR sequence number:** Accept default or specify custom number
2. **Confirmation:** Review summary, type `y` to proceed

**Expected output:**
```
✓ Resolved: adr_example_name.md
ADR sequence number [001]: 001

=== Promotion Summary ===
Type:        ADR
Source:      /home/ch1ch0/.nb/t480/adr_example_name.md
Destination: /home/ch1ch0/projects/labs/t480/ADR/ADR-001-example-name.md

Proceed? (y/N)
```

### 4. Review promoted artifact

```bash
# Open in editor
vim ADR/ADR-001-example-name.md

# Check for:
# - Formatting correctness
# - Content accuracy
# - No sensitive data (secrets, internal IPs, etc.)
```

**If edits needed:**
```bash
# Make changes in editor, then:
git add ADR/ADR-001-example-name.md
git commit -m "docs: review and update promoted ADR"
```

### 5. Merge promotion branch

```bash
# Switch to main branch
git checkout main

# Merge promotion branch
git merge nb-promote/<name>

# Verify merge
git log --oneline -3
```

### 6. Clean up promotion branch

```bash
# Delete merged branch
git branch -d nb-promote/<name>

# Verify branches
git branch -a
```

### 7. Mark original artifact in nb

```bash
# Edit original nb artifact
nb t480:<id> --edit

# Append promotion metadata at end of file:
---
**Promoted to Git:** YYYY-MM-DD 
**Repo path:** `ADR/ADR-NNN-example-name.md`
**Commit:** <commit-hash>
```

**Purpose:** Creates audit trail, prevents duplicate promotion, indicates artifact is "published"

### 8. Verify final state

```bash
# In Git repo
ls -la ADR/
git log --oneline -3

# In nb
nb t480:show <id>
```

## Promotion Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ nb workspace (operational, iterative)                       │
│ ~/.nb/t480/adr_example.md                                   │
└────────────────┬────────────────────────────────────────────┘
                 │
                 │ Meets promotion criteria?
                 │ (finalized, complete, stable)
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ Run: scripts/nb-promote.sh t480:adr_example.md              │
│                                                             │
│ 1. Creates branch: nb-promote/example                       │
│ 2. Copies file to ADR/ADR-NNN-example.md                    │
│ 3. Commits to branch                                        │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ Review & edit (optional)                                    │
│ vim ADR/ADR-NNN-example.md                                  │
│ git commit -m "docs: review and update"                     │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ Merge to main                                               │
│ git checkout main && git merge nb-promote/example           │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ Mark in nb with promotion metadata                          │
│ nb t480:adr_example.md --edit                               │
│ (Append: promoted date, path, commit)                       │
└─────────────────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ Git repo (version-controlled, public portfolio)             │
│ ~/projects/labs/t480/ADR/ADR-NNN-example.md                 │
└─────────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Problem: Script fails with "Invalid nb convention"
**Cause:** Filename doesn't start with `adr_`, `runbook_`, `incident_`, or `log_`

**Solution:** Rename file in nb to follow convention:
```bash
# Check current filename
nb t480:<id> --path

# Rename using nb
nb t480:rename <id> --filename adr_<new-name>.md
```

### Problem: Script fails with "Repo has uncommitted changes"
**Cause:** Git working tree is dirty

**Solution:** Commit or stash changes before promotion:
```bash
cd ~/projects/labs/t480
git status
git add -A && git commit -m "wip: ongoing work"
# Or: git stash
```

### Problem: ADR numbering conflict
**Cause:** Manual ADR creation or concurrent promotions

**Solution:** Specify different sequence number when prompted, or renumber existing ADRs

### Problem: Filename has special characters breaking shell
**Cause:** Spaces, parentheses, or other shell metacharacters in filename

**Solution:** Use ID instead of filename:
```bash
nb t480:  # Find ID number
scripts/nb-promote.sh t480:<id>
```

### Problem: Promoted file missing content after merge
**Cause:** Wrong branch merged or file not staged

**Solution:** Check branch history and file content:
```bash
git log --all --oneline -- ADR/ADR-NNN-example.md
git show HEAD:ADR/ADR-NNN-example.md
```

## Maintenance

### Adding new notebook support
Edit `scripts/nb-promote.sh` and add case in repo determination:
```bash
case "$NOTEBOOK" in
    t480) REPO="$T480_REPO" ;;
    srv-m1m) REPO="$SRVMIM_REPO" ;;
    new-notebook) REPO="$HOME/projects/labs/new-notebook" ;;
    *) die "Unsupported notebook: $NOTEBOOK" ;;
esac
```

### Changing ADR numbering scheme
Modify `scripts/nb-promote.sh` in the ADR filename generation section.

### Auditing promoted artifacts
```bash
# Find all promoted artifacts in nb
grep -r "Promoted to Git" ~/.nb/t480/

# Find all ADRs in repo
find ~/projects/labs/t480/ADR -name "ADR-*.md" | sort
```

## Related Documentation
- ADR: `adr_nb_promotion_workflow.md` (in nb) - Design decisions
- Script: `scripts/nb-promote.sh` - Automation implementation
- Charter: `T480-CHARTER.md` - Overall workflow governance

## Revision History
- 2026-01-20: Initial version, documents first successful promotion workflow
