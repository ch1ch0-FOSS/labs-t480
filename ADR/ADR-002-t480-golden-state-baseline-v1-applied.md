# ADR-002: T480 golden-state baseline v1.0 applied

**Status:** Accepted  
**Date:** 2026-01-20  

## Context

- The lab uses the T480 as the primary control-plane workstation for Ansible, CI, and documentation.
- The goal is to create a repeatable “golden state” baseline that:
  - Aligns with RHEL / LPIC expectations.
  - Favors a terminal-first, Vi-centric workflow.
  - Remains close to stock RHEL so skills transfer cleanly to other environments. 
- Session work and previous notes identified a core set of tools and conventions that were being used informally on T480 without being fully codified. [file:94]

## Decision

Define and apply a golden-state baseline v1.0 for T480 with these characteristics:

- **Base alignment:**
  - Treat standard RHEL/LPIC tooling and defaults as the baseline.
  - Keep most configuration close to defaults so vendor documentation and man pages remain accurate. 
- **Additional tools on top of the baseline:**
  - `nb` as the primary PKM and infra design tool (notes, ADRs, incidents, logs, bookmarks).
  - `vimb` as the only GUI browser, used when a graphical web view is required.
  - `syncthing`, `tailscale`, `curl`, `wget`, `w3m`, `ddgr`, `wl-clipboard`, and similar small utilities to support modern workflows while remaining CLI-first. [file:94]
- **Workflow conventions:**
  - Vi-style keybindings wherever possible to build universal muscle memory across tools.
  - Markdown as the universal documentation format.
  - “Terminal first” as the default interaction model; GUI usage is the exception, not the rule. [file:94]
- **Configuration stance:**
  - Avoid heavy customization or plugin ecosystems that diverge from what another RHEL admin would expect.
  - Treat Caps Lock remapping to Escape as a deliberate but minimal ergonomic change. [file:94]

These choices are implemented and enforced through the `t480-baseline.yml` Ansible playbook defined in ADR-001. 

## Rationale

- Aligning with RHEL/LPIC and keeping close to defaults makes T480 a realistic training and portfolio environment; skills demonstrated here map directly to typical enterprise RHEL systems. 
- Standardizing on `nb`, Markdown, and Vi-motions reduces context switching and supports deep CLI proficiency.
- Choosing a single GUI browser (`vimb`) bounds the graphical surface area while still allowing access to web-based docs and tools when needed. [file:94]
- Minimal customization reduces the risk of “works on my machine” configs that are hard to reproduce or explain in interviews.

## Alternatives Considered

- **Full desktop-centric workflow with multiple GUI apps:**  
  Rejected; this dilutes the terminal-first focus and makes it harder to practice RHEL-style CLI operations.
- **Heavy dotfile setups (e.g., large plugin ecosystems for shell/editor):**  
  Rejected for the baseline; such setups are harder to explain, harder to port, and deviate from standard RHEL environments.
- **Using SaaS PKM tools instead of local `nb`:**  
  Rejected; this conflicts with the lab’s vendor-agnostic, local-first, and self-hosted principles.

## Consequences

- Rebuilding T480 from scratch now has a clear target: “golden-state v1.0 as defined in ADR-001 and ADR-002, enforced by Ansible.” 
- New tools or significant workflow changes must either:
  - Fit within this baseline philosophy, or
  - Be introduced via new ADRs that update or supersede this one.
- Team members and interviewers can see a concrete, opinionated, but RHEL-aligned workstation baseline, improving portfolio value.
- Some convenience from rich desktop environments is intentionally sacrificed in favor of repeatability, portability, and skill transfer.

## Related

- ADR-001: T480 golden-state Ansible structure.
- T480 MOC: `moc_t480.md` (nb notebook).
- nb promotion runbook: `runbooks/RUNBOOK-nb-to-repo-promotion.md`.
