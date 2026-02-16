# ADR 002: Workstation Security Hardening

## Status

**Accepted** - February 2026

## Context

A production-grade workstation requires security hardening to protect infrastructure credentials and prevent compromise. This ADR documents the security decisions for the T480 control plane.

## Decision

Implement defense-in-depth security with multiple layers of protection.

### Security Layers

1. **System Security**
   - SELinux in enforcing mode
   - Firewalld with restrictive default rules
   - Automatic security updates enabled

2. **Access Control**
   - SSH key-based authentication only
   - No password-based SSH access
   - Separate user account (not root)

3. **Network Security**
   - Tailscale VPN for all infrastructure access
   - No direct SSH to servers from external networks
   - Firewall blocks incoming connections

4. **Credential Management**
   - SSH keys stored in hardware-backed location
   - No hardcoded credentials in Ansible
   - Ansible Vault for sensitive variables

5. **Endpoint Protection**
   - fail2ban for brute-force protection
   - Audit logging for compliance
   - Regular security scans

## Consequences

### Positive
- Credentials protected by multiple layers
- Audit trail for compliance
- Minimal attack surface
- Demonstrates enterprise security practices

### Considerations
- Some convenience trade-offs (key management)
- Requires Tailscale for remote access

## References

- CIS Benchmarks for Linux
- Fedora Security Guide
- Ansible SSH Hardening Role
