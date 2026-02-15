# SYSTEM-SPEC: x86_64 Control Plane (ThinkPad T480)

**Owner:** ch1ch0  
**Created:** 2026-01-16 13:00 EST  
**Status:** IMMUTABLE (v1.0)  
**Last Updated:** 2026-01-16 13:00 EST

---

## 1. Purpose & Role

Define the non-negotiable hardware, OS, and usage baseline for the Lenovo ThinkPad T480 as the **x86_64 control plane** for the Asahi ARM64 server and the wider portfolio infrastructure.

This spec is the authoritative description of how the T480 participates in the system. It is **not** a monitoring snapshot; current state is captured separately in `SYSTEM-SPECS.md` generated from audit logs.

The T480:

- Acts as the primary **operator workstation** (tmux, SSH, editors).
- Acts as the **Ansible control node** and orchestration point targeting the Asahi ARM64 host and future nodes.
- Acts as the **Git / CI client** for Forgejo and Woodpecker, initiating and inspecting pipelines that run against `/mnt/asahi` on the Asahi server.

---

## 2. Hardware Baseline

These characteristics are treated as stable assumptions for design and capacity planning:

- **Platform:** Lenovo ThinkPad T480 (model 20L50018US)
- **CPU:** Intel Core i7-8650U, 4 cores / 8 threads @ 1.90 GHz (turbo to ~4.2 GHz)
- **RAM:** 32 GiB system memory (31 GiB usable reported)
- **Graphics:** Integrated Intel UHD Graphics 620 (Kaby Lake-R GT2)  
- **Firmware:** BIOS ThinkPad T480, version N24ET81W (1.56), dated 2025-09-06

Thermal and power characteristics (laptop form factor) mean this host is not intended for sustained high-CPU, high-IO production services.

---

## 3. Operating System & Base Stack

The T480 runs a stable Fedora Server environment:

- **OS:** Fedora Linux 43 (Server Edition), x86_64[file:122]  
- **Kernel:** 6.18.5-200.fc43.x86_64 (or later 6.18.x Fedora kernel in the same family)
- **Init:** systemd  
- **Package manager:** dnf  
- **Primary shell:** Bash

Usage rules:

- Major OS upgrades (e.g., Fedora 43 → 44) require an ADR and spec version bump, to keep the control plane predictable alongside the ARM64 Asahi baseline.

---

## 4. Storage & Data Roles

The T480 uses a single internal NVMe SSD for the OS and user data. From current audits:

- **System disk:** NVMe SSD with partitions for EFI (`/boot/efi`), `/boot`, and an LVM-backed XFS root filesystem.
- **Key mountpoints:**
  - `/boot/efi` – EFI system partition (vfat/FAT32)[file:122]
  - `/boot` – XFS filesystem for kernels and bootloader data[file:122]
  - `/` – XFS root filesystem (LVM logical volume, details in audit logs)

Control-plane data expectations:

- Local clones of infrastructure repositories (e.g. under `~/projects/` and/or `/mnt/data/git`) used to drive Asahi and other hosts.
- Local configuration for:
  - Ansible inventories and playbooks.
  - SSH profiles and tmux layouts.
  - CLI tooling for Forgejo, Woodpecker, Prometheus, etc., while the *services* themselves live on the Asahi server per its SYSTEM-SPEC.

The T480 **does not** host primary production databases or long-lived service data; all critical state is on the Asahi server or external backup targets.

---

## 5. Control-Plane Responsibilities

Logical responsibilities of the T480:

- **Orchestration**
  - Run Ansible playbooks against the Asahi M1 server and any future hosts.
  - Maintain inventories and group variables that encode the relationship between `/mnt/asahi`, `/mnt/data`, and `/mnt/fastdata` on the ARM64 platform.

- **Development & CI**
  - Act as the main editing environment for infrastructure-as-code (Ansible, Rust tooling, shell scripts).
  - Interact with Forgejo (Git) and Woodpecker (CI) as a client, not as a service host, using the T480’s stable x86_64 environment for local testing.

- **Operations & Access**
  - Primary SSH jump host and tmux environment for managing the Asahi server and associated services.
  - Fallback operations console when Asahi is degraded: the T480 must remain able to reach Asahi via SSH/Tailscale and apply remediation steps.

These responsibilities shape how monitoring, backups, and access controls are designed around the T480.

---

## 6. Constraints & Out-of-Scope

Constraints:

- **Mobility & power:** As a laptop, the T480 may be suspended, moved, or running on battery; designs must tolerate temporary unavailability of the control plane.
- **Compute & thermals:** Not intended for sustained production workloads at high CPU or IO utilization.
- **Storage:** Single internal disk; no local RAID or high-availability storage features. Resilience is handled via backups and the Asahi server’s storage tiers.

Out-of-scope for this spec:

- Hosting primary production databases (PostgreSQL) or metrics stores (Prometheus) long-term.
- Running core infra services (Forgejo, Woodpecker, Prometheus, Grafana, Vaultwarden) in production; those belong to the Asahi platform.
- Acting as a Kubernetes cluster or complex container orchestrator for production workloads.

---

## 7. Portfolio & AI–Human Workflows

This document is designed as a **source of truth** for both humans and AI assistants:

- AI tools may:
  - Read this file to understand the T480’s role, constraints, and baseline when generating playbooks, runbooks, or DR plans.
  - Cross-reference `SYSTEM-SPECS.md` for current state, while treating this spec as the normative intent.

- Humans may:
  - Use this spec when reasoning about control-plane design in ADRs.
  - Present it in interviews to demonstrate deliberate documentation, separation of concerns (control plane vs workload host), and readiness for AI-assisted operations.

`SYSTEM-SPECS.md` should be regenerated regularly using `t480-audit.sh` and `generate-system-specs.sh`, and treated as telemetry; this SYSTEM-SPEC file changes only via the amendment rules below.

---

## 8. Amendment Rules

SYSTEM-SPEC-T480 is a gospel document:

Any change to:

- Hardware assumptions (e.g., RAM upgrades, disk layout changes).
- OS baseline (e.g., Fedora major version).
- Control-plane responsibilities or constraints.

MUST:

1. Create or update an ADR under `ADR/` describing the change and rationale.  
2. Bump the version in this header (v1.0 → v1.1, etc.).  
3. Update a decision index (e.g. `DECISION-INDEX.md`) with date, summary, and ADR link.  
4. Be logged in a `logs/session/YYYYMMDD-t480-system-spec-update.md` session file.

No direct edits without this process.

---

## 9. Version History

## 10. Golden State v1.0

The T480 golden state v1.0 defines the non-negotiable package set, services, and policies that this host must have to function as the x86_64 control plane.

- Package and tooling baseline is defined in `t480-system/golden-state-v1.md`.
- Services and policies (firewalld, sshd, SELinux, chronyd, libvirtd, syncthing, tailscale) are applied to keep the system in an LPIC/RHCSA-aligned, security-conscious state.
- Any change to the golden state document requires a matching SYSTEM-SPEC version bump and ADR entry.


### v1.0 (2026-01-16)

- Initial baseline specification for the ThinkPad T480 as the x86_64 control plane for the Asahi ARM64 server and portfolio infrastructure.
- Hardware/OS values sourced from the initial `SYSTEM-SPECS.md` generated by `t480-audit.sh` and `generate-system-specs.sh` on Fedora 43.

