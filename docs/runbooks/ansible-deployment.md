# Ansible Deployment Runbook

## Overview

This runbook describes how to deploy and manage infrastructure using Ansible from the T480 control plane.

## Prerequisites

- T480 with Ansible installed
- SSH access to target hosts
- Tailscale connection to srv-m1m

## Running Playbooks

### Run All Workstation Configuration

```bash
cd ~/iac
ansible-playbook playbooks/workstation.yml
```

### Run Specific Role

```bash
# Only security hardening
ansible-playbook playbooks/workstation.yml --tags security

# Only development tools
ansible-playbook playbooks/workstation.yml --tags devtools
```

### Deploy to srv-m1m

```bash
# Deploy monitoring
ansible-playbook playbooks/monitoring-deploy.yml

# Deploy specific service
ansible-playbook playbooks/deploy-forgejo.yml
```

## Troubleshooting

### SSH Connection Issues

```bash
# Test connectivity
ssh -v srv-m1m

# Check SSH config
cat ~/.ssh/config
```

### Playbook Failures

```bash
# Run with increased verbosity
ansible-playbook playbooks/workstation.yml -vvv

# Check specific task
ansible-playbook playbooks/workstation.yml --tags security --check
```

### Verify Changes

```bash
# Check mode=delta
ansible-playbook playbooks/workstation.yml --diff
```

## Best Practices

1. **Always use --check** before production runs
2. **Review the diff** with --diff flag
3. **Test on one host** first with --limit
4. **Use tags** to run specific sections
5. **Keep logs** of infrastructure changes
