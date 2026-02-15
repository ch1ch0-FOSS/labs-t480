# ADR-001: T480 golden-state Ansible structure

**Status:** Accepted  
**Date:** 2026-01-20  

## Context

- The T480 is the control-plane workstation for the local lab, used to drive Ansible, CI, and documentation.
- A “golden state” baseline for T480 is required so the machine can be rebuilt or converged to a known-good configuration at any time.
- Without a clear Ansible structure, configuration drifts into ad-hoc shell changes and manual tweaks that are hard to reproduce or audit. 

## Decision

Define a minimal, explicit Ansible structure for managing the T480 golden state:

- Use a single inventory entry for T480 with a local connection:
  - Inventory path: `labs/t480/ansible/inventory`.
  - Host definition: `t480 ansible_connection=local`. 
- Use one primary baseline playbook:
  - Playbook path: `labs/t480/ansible/t480-baseline.yml`.
  - Purpose: “Apply golden state v1.0 to the T480.” 
- Group tasks in the baseline playbook roughly by concern:
  - `packages` – install required packages from the golden-state definition.
  - `services` – enable/disable and set service states.
  - `selinux` – ensure SELinux is enforcing/targeted with correct config.
  - `firewalld` – manage default zone and allow SSH access.
  - `ssh` – enforce SSH hardening (no root login, etc.). 
- Defer Ansible roles until they are clearly needed:
  - Future path for a role: `labs/t480/ansible/roles/t480_baseline/`.
  - Do not introduce roles for the first baseline; keep everything in a single play for now. 

## Rationale

- A single, clearly named inventory and baseline playbook keeps the T480 configuration easy to understand for future operators.
- Grouping tasks by concern mirrors common RHEL hardening and configuration guides, making it easier to map between documentation and playbook structure. 
- Starting without roles keeps the initial implementation simpler and reduces abstraction overhead while the baseline is still evolving.
- Using `ansible_connection=local` matches the reality that T480 manages itself and avoids SSH round-trips for local convergence. 

## Alternatives Considered

- **Multiple playbooks per area (packages.yml, services.yml, etc.):**  
  Rejected for now; this would fragment the baseline and make it harder to see the full state in one place.
- **Role-first design (`t480_baseline` role from day one):**  
  Rejected initially; roles add value once patterns are stable or reused across hosts, but are premature for a single host baseline. 
- **Manual configuration without Ansible:**  
  Rejected; this cannot guarantee repeatability or auditability and conflicts with infra-as-code goals. 

## Consequences

- The T480 golden state can be applied with a single playbook, improving reproducibility and DR.
- Future changes to T480 must be reflected in `t480-baseline.yml` to avoid configuration drift.
- If the baseline grows significantly or is reused for other hosts, the team will revisit introducing roles and possibly restructuring plays. 
- This ADR becomes the reference when discussing how T480 is configured in interviews, documentation, and future ADRs.

## Related

- ADR-002: T480 golden-state baseline v1.0 applied.
- T480 MOC: `moc_t480.md` (nb notebook).
