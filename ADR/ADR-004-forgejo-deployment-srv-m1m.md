# ADR-004: Forgejo Deployment on srv-m1m

## Status
**Accepted**

## Context
Need to deploy Forgejo v11.0.0 on srv-m1m as part of baseline services, following existing ADRs for service management decisions and data/device separation.

## Decision
Deploy Forgejo using Ansible from T480 control plane to srv-m1m services node with:
- SQLite database (simple starting point)
- Systemd service management 
- Data under `/mnt/data/srv/forgejo`
- HTTP access on port 3000 initially

## Alternatives Considered
1. **Container deployment**: Rejected due to preference for systemd-managed services in baseline
2. **External PostgreSQL**: Deferred for v1.0, will migrate when v1.1 baseline is established
3. **Package manager installation**: Rejected in favor of direct binary download for version control
4. **Separate service repo**: Rejected - using srv-m1m repo maintains device-repo separation pattern

## Rationale
- **Device-repo separation**: srv-m1m should maintain its own configuration state in separate repo from T480 control plane
- **Version control**: Direct binary download with SHA256 verification ensures reproducible deployments
- **Data path consistency**: Using `/mnt/data/srv/forgejo` follows existing ADR patterns for capacity-tiered storage
- **Simplicity**: SQLite reduces operational complexity while maintaining functionality for evaluation phase

## Implementation
- Ansible role in `srv-m1m/ansible/roles/forgejo/`
- Variables in `srv-m1m/ansible/group_vars/all.yml`
- Integration into existing `srv-m1m-baseline.yml`
- Deployment via `ansible-playbook` from T480

## Consequences
- **Positive**: Simplified initial Forgejo deployment, version-controllable, follows established patterns
- **Negative**: Additional complexity in T480 deployment process (cross-repo execution)

## Notes
- Need to generate Forgejo admin access token for initial setup
- Must update T480 inventory to include srv-m1m host entry
- SELinux contexts may need adjustment for `/mnt/data/srv` access patterns