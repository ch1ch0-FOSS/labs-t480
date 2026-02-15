## repo.md

## Provisioning

All active Ansible for this system lives in the central IaC repo:

- Repo: ssh://forgejo@srv-m1m.tail929915.ts.net/ch1ch0/IaC.git
- Playbooks: playbooks/t480-baseline.yml, playbooks/t480-thinkorswim.yml, etc.

```markdown
<repo>
  <system_overview>
    This repo defines the ThinkPad T480 as the control-plane workstation for a small Fedora/RHEL lab.
    The lab includes an Asahi-based server (srv-m1m) as the primary services and data hub, plus additional nodes such as raspi4.
    The focus is senior-level, interview-defensible Linux infrastructure, with automation and documentation kept in sync.
    All infrastructure changes, documentation updates, and experiments should be initiated from the T480 using Linux CLI tools (Ansible, systemd, podman/containers, ssh) and the nb notebook system for documentation.[3]
  </system_overview>

  <device_t480>
    <role>
      Primary admin and development workstation.
      Control plane for Ansible, CI orchestration, and documentation authoring.
      Source of truth for nb-based documentation and CLI-driven workflows across all devices.[3]
    </role>
    <paths>
      <ansible>ansible/</ansible>
      <runbooks>runbooks/</runbooks>
      <adr>ADR/</adr>
      <audits>audits/</audits>
      <ci>ci/</ci>
      <scripts>scripts/</scripts>
      <system>t480-system/</system>
      <troubleshoot>troubleshoot/</troubleshoot>
      <archive>archive/</archive>
    </paths>
    <baseline>
      Golden state for t480 is defined in Ansible playbooks (for example, t480-baseline.yml) and validated by local scripts under scripts/.
      Audits and system specs under audits/ and t480-system/ describe the expected package set, services, and security posture for the control-plane workstation.
      Validation scripts (such as t480-baseline-validate.sh) assert the presence of required packages, binaries, and services to keep t480 in a reproducible state.
      Daily operations, ADR drafting, incident writeups, and runbook authoring are performed from the T480 using nb notebooks and standard Linux tools (vim, git, ssh, systemctl, podman).[3]
    </baseline>
    <notes>
      All operational changes should be initiated and recorded from the T480 where possible.
      This repo is the source of truth for how T480 participates in and manages the lab.
      Day-to-day, t480 is used to:
        - run Ansible against srv-m1m and other nodes,
        - manage CI configurations,
        - edit documentation (ADRs, runbooks, logs) using nb and vim,
        - collect audits and troubleshooting outputs via CLI tools.
      Direct changes on srv-m1m or other nodes should be rare and must be captured after the fact in this repo and in nb.[3]
    </notes>

    <nb_workflow>
      <notebooks>
        t480: control-plane ADRs, logs, and MOC.
        srv-m1m: services node ADRs, incidents, and MOC.
        linux-pro: RHEL/LPIC study notes and runbooks.
        toolkit: local docs for tools (nb, vim, w3m, vimb, etc.).
        inbox: todos and scratch.[4]
      </notebooks>
      <mocs>
        Each notebook has a Map of Contents note (MOC) acting as an operational dashboard.
        MOCs are hand-curated, Zettelkasten-style hub notes:
          - Context for the notebook's domain.
          - Command-first discovery snippets (nb ls, nb daily, etc.).
          - Key recent decisions, incidents, and promoted artifacts.
        Automation for MOCs is intentionally avoided to preserve nb’s pinning and browsing behavior.[5][6][7]
      </mocs>
      <promotion>
        ADRs, runbooks, and other durable artifacts are drafted in nb and promoted into this repo when they stabilize:
          - scripts/nb-promote.sh promotes nb ADRs into ADR/ADR-<NNN>-*.md on a short-lived branch.
          - runbooks/RUNBOOK-nb-to-repo-promotion.md documents the promotion process and criteria.
        nb notes remain the working area; ADR/ and runbooks/ store curated, interview-ready documents.[8][9][10][11]
      </promotion>
      <backup>
        The t480 nb notebook (~/.nb/t480) is considered critical data.
        An ADR in nb defines a backup strategy using a local bare Git repo under ~/Sync/nb-backups/t480.git.
        A runbook (RUNBOOK-nb-backup-restore.md) will describe manual backup and restore procedures and may later be extended to push to srv-m1m/Forgejo once the services node is re-aligned via Ansible.[6]
      </backup>
    </nb_workflow>
  </device_t480>

  <device_m1m>
    <role>
      Primary services and data node, running core lab services (Forgejo, CI, databases, monitoring, secrets).
      Target for most Ansible-driven deployments and service configurations initiated from T480.
      Operated primarily via SSH and Ansible from the T480, not by interactive local configuration.[3]
    </role>
    <services>
      <git>Forgejo (Git hosting, deployed)</git>
      <ci>Woodpecker CI (planned)</ci>
      <database>PostgreSQL</database>
      <monitoring>Prometheus, Grafana (planned)</monitoring>
      <secrets>Vaultwarden</secrets>
      <other>Additional app services, typically via systemd units or containers</other>
    </services>

    <storage>
      /mnt/data is the primary capacity-tier data and services mount for srv-m1m.
      /srv is a bind mount of /mnt/data/srv and is the canonical service root for Forgejo, Vaultwarden, and future services that should live on the capacity tier.
      Service data is expected to live under /mnt/data/srv/&lt;service&gt; (for example, /mnt/data/srv/forgejo and /mnt/data/srv/vaultwarden), presented to the system as /srv/&lt;service&gt;.[3]
      PostgreSQL currently uses its default OS data directory (for example, /var/lib/pgsql/data); migration to a performance tier such as /mnt/fastdata is deferred to a dedicated playbook and ADR.[3]
      Forgejo’s binary, configuration, data, and logs are all located under /mnt/data/srv/forgejo to keep git hosting on the capacity tier and aligned with existing backup routines.[2][1]
    </storage>

    <forgejo>
      <layout>
        Forgejo user and group: forgejo:forgejo, managed by Ansible.
        Application home: /mnt/data/srv/forgejo on /dev/sdb1 (btrfs, /mnt/data).
        Binary: /mnt/data/srv/forgejo/forgejo
        Config: /mnt/data/srv/forgejo/app.ini
        Data: /mnt/data/srv/forgejo/data/forgejo.db (SQLite)
        Logs: /mnt/data/srv/forgejo/log/gitea.log[1][2]
      </layout>
      <systemd>
        Unit file: /etc/systemd/system/forgejo.service (Ansible-managed).
        Key directives:
          - User=forgejo, Group=forgejo
          - WorkingDirectory=/mnt/data/srv/forgejo
          - ExecStart=/mnt/data/srv/forgejo/forgejo web --config=/mnt/data/srv/forgejo/app.ini
          - Restart=always, RestartSec=5s
        Service state:
          - forgejo.service enabled and active.
          - HTTP listener on 0.0.0.0:3000 verified via ss and curl.
          - Web UI serves the Forgejo installation page at <http://srv-m1m:3000/.>[2]
      </systemd>
      <ansible>
        Variables:
          - forgejo_home=/mnt/data/srv/forgejo
          - forgejo_binary=/mnt/data/srv/forgejo/forgejo
          - forgejo_config=/mnt/data/srv/forgejo/app.ini
          - forgejo_data_dir=/mnt/data/srv/forgejo/data
          - forgejo_log_dir=/mnt/data/srv/forgejo/log
          - forgejo_version=11.0.0, forgejo_arch=linux-arm64
          - forgejo_download_url and checksum pinned to Codeberg release.[6][1]
        Role: ansible/roles/forgejo
          - Creates forgejo system user/group.
          - Ensures /mnt/data/srv and /mnt/data/srv/forgejo exist with correct ownership.
          - Downloads Forgejo binary to forgejo_binary.
          - Creates data and log directories under forgejo_home.
          - Renders app.ini from app.ini.j2 with DB path, HTTP port 3000, and ROOT_URL=http://srv-m1m:3000/.
          - Installs forgejo.service under /etc/systemd/system and enables it.[12][13][1]
        Playbooks:
          - deploy-forgejo.yml: primary deploy entry point for srv-m1m Forgejo; includes forgejo role and prints effective configuration (version, arch, data directory, listen port, root URL).
          - deploy-forgejo-explicit.yml: troubleshooting harness that hardcodes paths and prints ls output after directory creation; kept for future debugging.[14][15][1]
      </ansible>
      <security>
        Current status:
          - SELinux can be set to enforcing; Forgejo has been validated with SELinux permissive during deployment troubleshooting.
          - The goal is to have a dedicated selinux_forgejo role that labels Forgejo binary and data directories appropriately and grants only minimal network and filesystem access.[16][2]
        Planned hardening:
          - Re-enable SELinux enforcing on srv-m1m, with targeted labels for /mnt/data/srv/forgejo, /mnt/data/srv/forgejo/data, and /mnt/data/srv/forgejo/log.
          - Tighten forgejo.service with resource limits (LimitNOFILE, MemoryMax) and systemd hardening options (PrivateTmp, ProtectSystem, NoNewPrivileges).
          - Optionally front Forgejo with NGINX to enforce TLS and security headers, with configuration managed in a dedicated role and documented in a runbook.[2]
      </security>
      <backup>
        Existing scripts:
          - /usr/local/bin/forgejo-backup.sh
          - /usr/local/bin/config-backup.sh
          - /usr/local/bin/pg-backup.sh
        Timers:
          - forgejo-backup.timer active and scheduled daily, running forgejo-backup.service.
        Coverage:
          - Backup layout assumes Forgejo lives under /mnt/data/srv/forgejo, matching the Ansible deployment.
          - Backups are expected to capture app.ini, data directory (including forgejo.db and attachments), and logs where needed for forensic review.
        Next steps:
          - Add runbooks/RUNBOOK-forgejo-backup-restore.md documenting manual backup invoke, restore steps, and validation.
          - Ensure backups are tested and DR procedures are interview-ready.[2]
      </backup>
    </forgejo>

    <runtime>
      Core services on srv-m1m are currently provided as systemd services:
        - postgresql.service
        - forgejo.service
        - vaultwarden.service
        - node_exporter.service
      The srv-m1m baseline Ansible playbook (srv-m1m-baseline.yml) is responsible for:
        - Validating Btrfs snapshots used as safety nets before structural changes.
        - Ensuring /srv is bind-mounted from /mnt/data/srv and required service directories exist.
        - Normalizing ownership and layout for Forgejo and Vaultwarden data under /mnt/data/srv.
        - Installing and maintaining vaultwarden.service and forgejo.service units with appropriate WorkingDirectory and configuration file paths.
        - Ensuring the above services are enabled and in the started state after a baseline run.[17][1]
      Rootless containers and more complex orchestration are considered future enhancements and are not assumed in the current baseline.
      All of these operations should be driven from the T480 using:
        - ssh t480 → srv-m1m
        - ansible-playbook against the srv-m1m inventory
        - systemctl, journalctl, podman, and standard Linux tools executed via SSH or Ansible tasks.[3]
    </runtime>
  </device_m1m>

  <other_devices>
    <raspi4>
      <role>
        Auxiliary lab node for monitoring targets, experiments, or edge workloads.
      </role>
      <management>
        Managed from T480 via Ansible and, where applicable, CI-driven workflows.
        Direct manual changes on the device should be rare and followed by documentation updates in nb and this repo.[3]
      </management>
    </raspi4>

    <containers>
      <role>
        Containerized workloads used for services and experiments, potentially hosted on srv-m1m and other container-capable hosts.
      </role>
      <notes>
        Containers should read and write data under well-defined directories (for example, under /mnt/data/srv on srv-m1m) instead of storing important state inside container layers.
        Where containers are introduced, their configuration should be driven from this repo (compose files, systemd units, or Ansible roles) and integrated with the existing storage layout.
        Container lifecycle (build, run, updates) should be controlled from the T480 via CLI (podman/docker, Ansible modules) and documented in nb runbooks.[3]
      </notes>
    </containers>

    <backup_targets>
      <role>
        Nodes or services that receive backups (local disks, NAS, cloud storage).
      </role>
      <notes>
        Backup targets are expected to integrate with srv-m1m and t480 workflows, with configuration and runbooks captured in this repo.
        Btrfs snapshots on /mnt/data and /mnt/fastdata are used as local safety nets; longer-term backups should be described under runbooks/ and ADR/.
        Backup and restore procedures should be executed and tested from the T480 using CLI tools (rsync, btrfs, borg/restic, etc.) and recorded in nb logs and runbooks.[3]
      </notes>
    </backup_targets>
  </other_devices>
</repo>

