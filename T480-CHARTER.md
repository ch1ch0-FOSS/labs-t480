# T480 charter

This document defines the governing rules for the T480 control-plane lab: how work is done, how AI and humans interact, and how this repo is maintained. It is the authoritative charter for `infra/t480`.

## Purpose

- Establish a single, coherent rule set for the T480-centered lab.
- Ensure that infrastructure, documentation, and automation are kept aligned.
- Provide interview-defensible evidence of systematic, senior-level practice.

## Scope

- Applies to all work performed under `~/projects/infra/t480`.
- Governs how T480 interacts with the Asahi server (`srv-m1m`), raspi4, containers, and related lab nodes.
- Covers documentation, automation (Ansible, CI, scripts), and use of this repo as a control-plane source of truth.

## Operating principles

- **Source of truth**: This repo is the canonical description of the T480’s role in the lab and the workflows used to manage lab systems.
- **Reproducibility**: Any non-trivial configuration or operational change should be:
  - encoded as code (Ansible, Terraform, scripts) where possible, and
  - documented in runbooks and, when appropriate, ADRs.
- **Simplicity first**: Prefer straightforward, inspectable solutions (e.g., Ansible and systemd over opaque SaaS or hidden magic).
- **Data safety**: Design with backup, restore, and auditability in mind from the beginning.

## Workflow rules

- **Change process**
  - Define changes in code and configuration managed in this repo.
  - Validate changes locally on T480 where reasonable before rolling out to other nodes.
  - Use Git branches and meaningful commit messages to document intent and scope.
- **Documentation updates**
  - When behavior, architecture, or expectations change, update:
    - `ARCHITECTURE.md` for structural or workflow changes.
    - Relevant `runbooks/RUNBOOK-*.md` for operational procedures.
    - `ADR/` entries for decisions with meaningful tradeoffs or impact.
- **Runbooks and ADRs**
  - Use runbooks for step-by-step operations (deployments, restores, audits, troubleshooting).
  - Use ADRs to record why a substantive decision was made and what alternatives were considered.

## AI–human interaction contract

- **No assumptions**
  - AI must not silently invent system state, configs, or workflows.
  - If required information is not available in this repo or the current session, AI should ask for:
    - specific file contents,
    - updated directory trees, or
    - clarification about current state.
- **Context discipline**
  - Refer to devices explicitly as T480, `srv-m1m`, raspi4, etc.
  - Refer to files and paths explicitly (e.g., `ansible/`, `runbooks/RUNBOOK-SSH-SRVMIM.md`).
  - Treat `ARCHITECTURE.md`, `README.md`, and `repo.md` as primary context anchors.
- **Session shape**
  - Keep sessions focused on small, well-defined tasks (e.g., “draft Ansible baseline for T480 packages”).
  - Avoid sprawling, multi-goal changes in a single pass.
  - At the end of any session involving material changes, ensure:
    - relevant docs and runbooks are updated or at least flagged for update,
    - open questions or follow-ups are clearly identified.

## Documentation standards

- Write in clear, concise Markdown, optimized for both senior engineers and future you.
- Prioritize accuracy and explicitness over brevity when describing critical operations (backups, restores, security, destructive actions).
- Use consistent naming patterns:
  - `RUNBOOK-*.md` for operational guides.
  - `SYSTEM-SPEC-*.md` for system spec descriptions.
  - Time- or subject-encoded names for ADRs and audit artifacts.
- Ensure that documentation changes are committed alongside or immediately after related code changes.

## Security and access

- Prefer key-based SSH and minimal necessary privileges for remote access.
- Document any elevated access patterns in runbooks, including:
  - when and why `sudo` is used,
  - how secrets are handled (e.g., via password managers or secret stores).
- Never hard-code secrets into this repo; instead:
  - store secrets in appropriate secure locations (e.g., Vaultwarden),
  - refer to them abstractly in documentation and automation.

## Evolution of this charter

- This charter is a living document.
- Substantive changes to these rules should:
  - be proposed and justified in a new ADR under `ADR/`,
  - be accompanied by an update to this file describing the change.
- The intention is that over time this charter becomes a stable, trustworthy foundation that accurately reflects how the lab is actually operated.

