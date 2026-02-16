# T480 Runbooks Overview

This directory contains operational procedures for the T480 control plane workstation.

## Available Runbooks

### Deployment & Configuration

- **[Ansible Deployment](ansible-deployment.md)** - How to run Ansible playbooks
- **[Workstation Setup](workstation-setup.md)** - Initial T480 configuration
- **[Dotfiles Management](dotfiles-management.md)** - Managing dotfiles with GNU Stow

### Security

- **[SSH Hardening](ssh-hardening.md)** - SSH security best practices
- **[Firewall Configuration](firewall-configuration.md)** - firewalld setup
- **[Tailscale Setup](tailscale-setup.md)** - VPN configuration

### Monitoring

- **[Monitoring Setup](monitoring-setup.md)** - Prometheus/Grafana configuration
- **[Alert Configuration](alert-configuration.md)** - Setting up alerts

### Backup & Recovery

- **[Backup Procedures](backup-procedures.md)** - Data backup strategies
- **[System Recovery](system-recovery.md)** - Disaster recovery steps

## Quick Reference

### Common Operations

```bash
# Run all workstation roles
ansible-playbook playbooks/workstation.yml

# Run specific role
ansible-playbook playbooks/workstation.yml --tags security

# Check system status
systemctl status node_exporter

# View logs
journalctl -u ansible -f
```

### Service Ports

| Service | Port | Status |
|---------|------|--------|
| node_exporter | 9100 | Metrics |

## Maintenance Schedule

- **Daily**: Check monitoring dashboards
- **Weekly**: Review security logs
- **Monthly**: Update packages
- **Quarterly**: Review Ansible roles for updates
