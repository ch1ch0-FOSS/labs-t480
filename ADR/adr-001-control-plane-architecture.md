# ADR 001: Control Plane Workstation Architecture

## Status

**Accepted** - February 2026

## Context

The T480 serves as the control plane in a two-node infrastructure architecture. This ADR documents the design decisions for using a laptop as an infrastructure control plane.

## Decision

Use the ThinkPad T480 as a dedicated control plane workstation that manages the srv-m1m data plane server via Ansible over SSH/Tailscale.

### Architecture Pattern

```
┌─────────────────┐         ┌──────────────────┐
│   T480         │         │   srv-m1m        │
│   (Control     │◄───────►│   (Data Plane)  │
│    Plane)      │ Tailscale│                  │
│                │  Network │ All production   │
│ Ansible        │         │ services          │
│ OpenCode       │         │                   │
│ Beads          │         │                   │
└─────────────────┘         └──────────────────┘
```

### Key Design Decisions

1. **Ansible as Control Plane**
   - All infrastructure managed via Ansible playbooks
   - 20+ roles for different components
   - Idempotent, reproducible configuration

2. **Tailscale for Connectivity**
   - Encrypted mesh VPN between control and data plane
   - Services accessible only via Tailscale (zero-trust)
   - No port forwarding or public exposure

3. **Local AI Integration**
   - OpenCode for AI-assisted development
   - DMR (Docker Model Runner) for local LLM
   - MCP Server for project context

4. **Beads for Task Management**
   - Local task/issue tracking
   - Replaces GitHub Issues for internal work
   - Tracked in git for audit trail

## Consequences

### Positive
- Demonstrates enterprise architecture patterns
- Secure by default (Tailscale-only access)
- Reproducible via Ansible
- Self-hosted, no external dependencies

### Considerations
- Requires Tailscale for all management
- Control plane needs reliable connectivity
- Both nodes must be online for management

## References

- T480 GitHub Repo: https://github.com/ch1ch0-foss/labs-t480
- Ansible Roles: https://github.com/ch1ch0-foss/iac (roles/)
