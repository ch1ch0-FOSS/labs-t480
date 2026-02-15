# ADR:nb backup strategy for t480

2026-01-21

#adr #backup #t480 #nb

## Context

- `~/.nb/t480` contains critical ADRs, logs, and operational notes for the T480 control-plane.
- Loss or corruption of this notebook would mean losing decision history and troubleshooting records that are not fully duplicated elsewhere.

## Decision

- Use Git to version-control `~/.nb/t480` to a private remote:
  - Initially a local/bare repo on T480 or srv-m1m.
  - Later, a Forgejo-hosted remote on srv-m1m once that service is in place.
- Start with a **manual** backup workflow, driven by an explicit script/runbook.
- Plan to automate backups via a `systemd` timer once the manual process is stable and trusted.

## Rationale

- Git fits the plain-text / Markdown nature of nb notebooks and supports history, diffs, and rollback.
- Keeping backups local (T480 + srv-m1m) aligns with the no-SaaS, self-hosted, vendor-agnostic principles.
- A manual-first process forces understanding and avoids hiding complexity behind automation prematurely.

## Consequences

- A dedicated runbook is required to document:
  - Initializing the backup repo.
  - Performing backups (committing and pushing changes).
  - Restoring `~/.nb/t480` onto a fresh T480 from the backup.
- Secrets and sensitive data stored in nb must be reviewed before any remote hosting (even self-hosted Forgejo) to avoid unintended exposure.
- Future automation (systemd timer) will need its own ADR or update to this one to cover scheduling, retention, and failure modes.

## References

- Related logs: `daily_2026-01-21.md` (session describing this decision).
- Related runbooks: `RUNBOOK-nb-backup-restore.md` (to be created in `~/projects/labs/t480`).
- Related ADRs:
  - ADR-001: T480 golden-state Ansible structure.
  - ADR-002: T480 golden-state baseline v1.0 applied.

