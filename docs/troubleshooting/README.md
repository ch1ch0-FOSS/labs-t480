# Troubleshooting Guide

This guide covers common issues and their solutions for the T480 control plane.

## Ansible Issues

### Cannot Connect to Target Host

**Symptoms**: Playbook fails with "UNREACHABLE"

**Diagnosis**:
```bash
# Test SSH connection
ssh -v srv-m1m

# Check Tailscale status
tailscale status
```

**Solutions**:
1. Verify Tailscale is connected
2. Check hostname resolves: `srv-m1m` should resolve to Tailscale IP
3. Verify SSH key is in authorized_keys on target

### Playbook Fails with Permission Error

**Symptoms**: "Permission denied" or "Become failed"

**Diagnosis**:
```bash
# Check if user can sudo
ssh srv-m1m 'sudo whoami'
```

**Solutions**:
1. Add `ansible_become: true` to inventory
2. Use correct become method: `ansible_become_method: sudo`
3. Verify user is in sudo group

### Idempotency Issues

**Symptoms**: Playbook reports changes every run

**Solutions**:
1. Check for missing `creates` parameter in command tasks
2. Review handler notifications
3. Verify template idempotency

## Tailscale Issues

### Cannot Reach srv-m1m

**Symptoms**: Connection timeout to srv-m1m

**Diagnosis**:
```bash
tailscale status
ping srv-m1m
tailscale ping srv-m1m
```

**Solutions**:
1. Ensure Tailscale is running on both hosts
2. Check subnet router is configured
3. Verify firewall allows Tailscale

### Tailscale Not Starting

**Symptoms**: `tailscaled` service not running

**Solutions**:
```bash
sudo systemctl start tailscaled
sudo systemctl enable tailscaled
journalctl -u tailscaled -n 50
```

## Monitoring Issues

### Prometheus Not Scraping Targets

**Symptoms**: Target shows as "DOWN" in Prometheus

**Diagnosis**:
```bash
# Check target endpoint
curl http://srv-m1m:9100/metrics

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets
```

**Solutions**:
1. Verify node_exporter is running on target
2. Check firewall allows port 9100 from Tailscale network
3. Verify scrape configuration in prometheus.yml

## System Performance

### High CPU Usage

**Diagnosis**:
```bash
htop
top -o %CPU
```

**Solutions**:
1. Check for runaway processes
2. Review system logs for errors
3. Consider reducing concurrent Ansible runs

### High Memory Usage

**Diagnosis**:
```bash
free -h
top -o %MEM
```

**Solutions**:
1. Close unused applications
2. Check for memory leaks
3. Increase swap if needed

## Recovery Procedures

### Complete Workstation Rebuild

```bash
# From T480
cd ~/iac
ansible-playbook playbooks/workstation.yml --tags bootstrap

# Then apply full configuration
ansible-playbook playbooks/workstation.yml
```

### Restore from Backup

See: [Backup Procedures](runbooks/backup-procedures.md)
