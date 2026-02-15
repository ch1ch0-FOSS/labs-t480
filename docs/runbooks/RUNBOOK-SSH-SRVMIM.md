# RUNBOOK-SSH-SRVM1M.md  
**SSH Access – srv-m1m from T480**

**Location:** `runbooks/RUNBOOK-SSH-SRVM1M.md`  
**Project:** `~/projects/infra/t480`  

---

## 1. Purpose and Scope

Define how the T480 control-plane connects to the Asahi M1 server (`srv-m1m`) over SSH.

- Focus: key-based SSH from T480 → srv-m1m.  
- Assumption: srv-m1m is on the same LAN (192.168.1.0/24) for now.  
- Later: Tailscale or other secure overlay can be documented separately.

This runbook is for day-to-day admin (tmux, Vim, Git, Ansible) on srv-m1m, initiated from the T480.

---

## 2. SSH Key Material on T480

SSH keys live under `~/.ssh` on the T480:

- Private key: `~/.ssh/id_ed25519`  
- Public key: `~/.ssh/id_ed25519.pub`  
- Authorized keys on srv-m1m: `/home/ch1ch0/.ssh/authorized_keys` includes `id_ed25519.pub`.

To inspect the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy this into `~/.ssh/authorized_keys` on srv-m1m (once) to allow key-based login.

---

## 3. SSH Client Configuration (T480)

Client configuration is in `~/.ssh/config`:

```sshconfig
Host srv-m1m
    HostName 192.168.1.64
    User ch1ch0
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    ServerAliveInterval 30
```

Meaning:

- `Host srv-m1m` – shorthand name used in `ssh srv-m1m`.  
- `HostName` – current LAN IP of the M1 server.  
- `User` – login user on srv-m1m.  
- `IdentityFile` – explicit private key to use.  
- `IdentitiesOnly yes` – prevents SSH from trying other keys/agents.  
- `ServerAliveInterval 30` – sends keepalives every 30 seconds to keep long sessions (tmux, Ansible) alive.

---

## 4. Testing Connectivity

From the T480:

```bash
ssh -v srv-m1m
```

Check for:

- Authentication with `id_ed25519` (look for `Offering public key: id_ed25519`).  
- Successful login as `ch1ch0` on srv-m1m.  
- No password prompts (key-based only).

Once confirmed, normal connections can be made with:

```bash
ssh srv-m1m
```

For tmux-based admin sessions:

```bash
ssh srv-m1m -t 'tmux new -A -s admin'
```

This attaches (or creates) a persistent admin tmux session on the server.

---

## 5. Ansible and Git Usage Notes

With SSH configured:

- **Ansible:** inventory entries for srv-m1m can use `ansible_host=srv-m1m` and rely on SSH config.  
- **Git / Forgejo:** clones and pushes from T480 to Forgejo on srv-m1m can use `ssh://srv-m1m/...` as the remote URL.

This keeps all tooling (ssh, git, ansible) using the same `Host srv-m1m` abstraction.

---

## 6. Future: Beyond the LAN

When srv-m1m needs to be reachable off-LAN:

- Introduce Tailscale or similar overlay and add a second SSH profile (e.g., `srv-m1m-tailscale`).  
- Keep the local-LAN `srv-m1m` host entry for on-site work.

Document that extended access in a separate Tailscale runbook once implemented.

---

**RUNBOOK-SSH-SRVM1M.md – v1.0**
