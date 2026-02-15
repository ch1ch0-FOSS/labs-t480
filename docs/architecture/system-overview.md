# T480 lab architecture

This document describes the architecture of the T480-centered lab, including roles of each device, service placement, and the main control and data flows.[file:19]

## System overview

At a high level:

- T480 is the **control-plane workstation**.
- Asahi server (`srv-m1m`) is the **primary services and data hub**.
- Additional nodes (e.g., `pixel`, `raspi4`, container hosts, cloud backup targets, future Raspberry Pi cluster) sit downstream of these two.

The control path runs primarily from T480 to `srv-m1m` and other nodes over SSH and automation tooling; observability and data services are anchored on `srv-m1m` and accessed from T480.

## Devices and roles

- **T480**
  - Daily driver workstation for administration and development.
  - Primary Git, Ansible, CI control point, and local VM host for LPIC/RHEL (RHCSA) practice (planned).
  - Documentation authoring and audit origin.
  - Personal knowledge base host (nb), with data synchronized and stored on `srv-m1m` to keep the laptop lean and PKM data centralized across devices.

- **Asahi server (`srv-m1m`)**
  - Primary services node for:
    - Forgejo (self-hosted Git).
    - Woodpecker CI.
    - PostgreSQL.
    - Prometheus and Grafana.
    - Vaultwarden.
    - Supporting services (e.g., nb sync target, Syncthing, other app containers).
  - Main data hub for lab services and PKM data replicated from T480 (and Pixel).

- **Pixel w/ GrapheneOS (`pixel`)**
  - Mobile admin device for light operational tasks and observability while away from the T480.
  - Professional contact device and additional secure point of control and status checking.
  - Candidate host for nb as a PKM capture surface, with data synchronized back to `srv-m1m` alongside T480 PKM data (planned).

- **raspi4**
  - Specialized node for monitoring, logging, and auxiliary services while keeping a small physical footprint.
  - Planned attachments:
    - Oyooso screen to act as a dedicated status/observability display.
    - 500 GB HDD to store logs, metrics, and other time-series or diagnostic data to offload storage from other nodes.
  - Managed from T480 and/or `srv-m1m` via Ansible and CI.

- **Additional Raspberry Pi nodes / cluster**
  - Future Raspberry Pi nodes may be added to form a small Kubernetes cluster for container orchestration and experimentation.
  - The cluster will be controlled from T480 (and integrated with `srv-m1m` services) for realistic homelab scheduling and deployment scenarios.

- **Other lab nodes**
  - Additional container hosts, backup targets, and cloud resources (once provisioned) that extend capabilities without changing the core T480↔`srv-m1m` relationship.
  - Managed from T480 using Ansible, CI pipelines, and documented runbooks.

## Service placement

Planned service location (subject to refinement via ADRs):

- On `srv-m1m`:
  - Forgejo (authoritative Git hosting for infra and lab projects).
  - Woodpecker CI (triggered by pushes to Forgejo).
  - PostgreSQL (backing data store for services).
  - Prometheus and Grafana (metrics and dashboards).
  - Vaultwarden (password and secret management).
  - Additional services packaged via Podman or other container tooling.

- On T480:
  - Local tooling (editors, CLI, Ansible, Terraform, CI runners as needed).
  - Local caches and working copies of repos.
  - Local-only configurations and scripts not intended for the server.
  - Local VMs for RHEL/Fedora certification practice and lab simulations (planned).

- On `pixel`:
  - Lightweight admin and observability tools appropriate for a mobile device.
  - Optional nb PKM client, with all data synchronized back to `srv-m1m`.
  - Termux for CLI SSH capabilities, if/as needed

- On `raspi4`:
  - Monitoring and logging support roles, especially once the Oyooso screen and 500 GB HDD are attached.
  - Potential collector/forwarder for metrics and logs, feeding Prometheus/Grafana on `srv-m1m`.

GitHub and other external services are treated, if used at all, as mirrors or optional integrations, not as sources of truth.

External cloud accounts or VMs are currently not provisioned but are considered a planned extension of this architecture.

## Tooling model (Day 0 / 1 / 2)

- **Day 0** – Provisioning:
  - Use Terraform or equivalent IaC tools (where appropriate) to define cloud or external dependencies once those accounts/VMs exist.
  - For bare metal (T480, `srv-m1m`, raspi4, additional Pis), document provisioning steps clearly in runbooks, including any manual install and initial configuration.

- **Day 1** – Baseline configuration:
  - Use Ansible from T480 to establish baseline OS configuration, users, packages, and hardening across lab nodes.
  - Capture device-specific constraints (e.g., Pixel, Asahi hardware specifics) in system spec and runbook documentation.

- **Day 2** – Ongoing changes:
  - Use Ansible, CI-driven pipelines, and container tooling (e.g., Podman, Kubernetes on the Pi cluster) to deploy and update services on `srv-m1m` and other nodes.
  - Capture any recurring procedures in `runbooks/` and `ADR/`.

The guiding principle is that reproducible changes should be encoded in code (Ansible, Terraform, scripts) and backed by documentation.

## Data and backup model

- Separate **device configuration** from **data**:
  - T480 and `srv-m1m` configs (system, services) are tracked in this repo and associated automation.
  - Service data (databases, repos, secrets, user data, PKM content) are stored on appropriate volumes or mounts and treated explicitly in backup strategies.

- Current state and direction:
  - Data/device separation is already implemented and documented on the Asahi server; T480 will move toward a similar separation as storage evolves (e.g., adding SSD or re-partitioning) but currently remains more monolithic.
  - PKM data from nb on T480 (and Pixel) is centralized on `srv-m1m` to keep endpoints lighter and to simplify backup and synchronization.

- Backups:
  - Implement a 3-2-1 style model (three copies, two media types, one offsite) for critical data where practical.
  - Use `raspi4` with attached HDD as one of the on-prem backup/observability layers for logs and metrics once the hardware is in place.
  - Maintain runbooks for:
    - Backup procedures for T480 and `srv-m1m`.
    - Restore and disaster recovery testing.

The intent is that restoring the lab should be a documented, testable process, not an improvised one.

## System workflow

High-level workflow and control/data paths:[file:19]

```text
+-------------------+          SSH / Git / CI control           +----------------------+
|    T480           |------------------------------------------>|  Asahi server        |
|  (control plane)  |                                           |  (srv-m1m, services) |
|                   |<------------------- dashboards / UX ------|                      |
+---------+---------+                                           +----------+-----------+
          |                                                              |
          | Ansible / scripts                                            | Metrics, backups
          v                                                              v
+---------+---------+                                           +----------+-----------+
|   raspi4 / other  |<----------------- monitoring / mgmt -----|  Backup / aux nodes  |
|   lab nodes       |                                           |  (cloud / storage)  |
+---------+---------+                                           +----------+-----------+
          ^
          |
          | Mobile admin / PKM sync
          |
+---------+-------------+
|   Pixel (GrapheneOS)  |
|   mobile admin / PKM  |
+-----------------------+
```

Typical flow:

- Configuration and code changes originate on T480, are committed to Git, and pushed to the lab Git host (intended to be Forgejo on `srv-m1m`).
- CI (e.g., Woodpecker) runs against this repo, validating changes and driving Ansible or container-based deployments to `srv-m1m`, `raspi4`, and other nodes.
- Monitoring data flows from all nodes to Prometheus/Grafana on `srv-m1m`; T480 is the primary console for viewing and acting on this data, with `raspi4` plus Oyooso screen serving as a dedicated status and monitoring display once fully set up.
- Logs and metrics can be offloaded to the 500 GB HDD on `raspi4` to reduce storage pressure on other nodes and provide a convenient review surface.
- PKM data (nb) is authored primarily on T480 (and possibly Pixel) and synchronized back to `srv-m1m` for centralized storage and backup.
- Backups of critical data (Git, databases, secrets, configs, PKM) are created from `srv-m1m` and/or T480 and pushed to designated backup locations, including on-prem nodes like `raspi4` and, when available, external cloud storage.


## Related documents

- `t480-system/SYSTEM-SPEC-T480.md` – detailed T480 hardware and system specs, including RAM and virtualization capabilities.
- `audits/` – system audits and environment snapshots for T480.
- `runbooks/` – operational procedures implementing the flows described here (backup, restore, monitoring, cluster management, etc.).
- `T480-CHARTER.md` – governance and workflow rules that apply to this architecture.
