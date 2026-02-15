# `nb` Installation via Ansible on T480

This document explains how `nb` is installed on the ThinkPad T480 using the baseline Ansible playbook, the issues encountered, and how to troubleshoot them. It is written to be usable offline and without external links.

## Goals

- Install `nb` in a **vendor-agnostic**, reproducible way as part of the T480 golden state.
- Keep `nb` fully under configuration management:
    - Source in `/usr/local/src/nb`.
    - Executable on the system-wide `PATH` as `/usr/local/bin/nb`.
- Avoid any dependency on distro-specific packages or third-party SaaS/package repositories.

***

## Final Design: How `nb` Is Installed

`nb` is distributed as a single script in a Git repository. The baseline playbook manages it in two layers:

1. **Source checkout** under `/usr/local/src/nb`.
2. **Executable symlink** from `/usr/local/src/nb/nb` to `/usr/local/bin/nb`.

### Ansible tasks (conceptual)

The relevant tasks in the baseline playbook are:

1. Ensure the source directory exists:

```yaml
- name: Ensure nb directory exists
  file:
    path: /usr/local/src/nb
    state: directory
    owner: root
    group: root
    mode: '0755'
```

2. Clone or update the upstream repository:

```yaml
- name: Clone or update nb from upstream git repo
  git:
    repo: https://github.com/xwmx/nb.git
    dest: /usr/local/src/nb
    version: main
    update: yes
```

3. Install `nb` onto the system `PATH`:

```yaml
- name: Install nb script into /usr/local/bin
  file:
    src: /usr/local/src/nb/nb
    dest: /usr/local/bin/nb
    state: link
    owner: root
    group: root
    mode: '0755'
```


Result:

- `nb` source lives in `/usr/local/src/nb`.
- `/usr/local/bin/nb` is a symlink pointing to the script in the source tree.
- `nb` is available to all users via the standard `PATH`.

***

## Problems Encountered

### 1. Treating `nb` as a distro package

**Symptom**

- `nb` was initially added to an Ansible package list (e.g. `t480_package_list_misc`) and installed via the `package` module.
- Running the baseline produced a failure for `nb` or silently did nothing, leaving `nb` unavailable.

**Cause**

- Fedora (and Fedora Asahi) does not ship `nb` as an RPM in the standard repositories.
- The `package` module can only manage what the package manager knows about; it cannot install arbitrary scripts from Git.

**Resolution**

- Remove `nb` from all `*_package_list_*` variables.
- Install `nb` from the upstream Git repository using the `git` and `file` modules as described in the “Final Design” section.


### 2. Confusion between source location and PATH

**Symptom**

- `nb` existed somewhere under `/usr/local/src`, but `nb` was not found when running `nb` from the shell.
- Alternatively, `/usr/local/bin/nb` existed but pointed to a missing or outdated file.

**Cause**

- Mixing up where the Git repo should live versus where the executable should live.
- Not using a stable symlink on `PATH` pointing into the source tree.

**Resolution**

- Standardize on:
    - Git repo: `/usr/local/src/nb`
    - Executable: `/usr/local/bin/nb` (symlink)
- Manage both locations explicitly in Ansible:
    - `git` module for the repository.
    - `file` module with `state: link` for the symlink.

***

## Verification Steps

After running the baseline playbook, verify that `nb` is correctly installed.

### 1. Check the source tree

```bash
ls -ld /usr/local/src/nb
ls /usr/local/src/nb
```

Expectations:

- `/usr/local/src/nb` exists and is owned by `root:root`.
- The directory contains at least the `nb` script and associated project files.


### 2. Check the symlink

```bash
ls -l /usr/local/bin/nb
```

Expectations:

- `/usr/local/bin/nb` exists.
- It is a symlink pointing to `/usr/local/src/nb/nb`.

Example:

```text
lrwxrwxrwx 1 root root 21 Jan 18 01:30 /usr/local/bin/nb -> /usr/local/src/nb/nb
```


### 3. Check that `nb` runs

```bash
which nb
nb help | head
```

Expectations:

- `which nb` returns `/usr/local/bin/nb`.
- `nb help` prints usage and help text without errors.

***

## Troubleshooting Guide

Use this checklist when `nb` is missing or broken after running the baseline.

### Scenario A: `nb` command not found

1. **Check PATH**

```bash
echo "$PATH"
which nb
```

    - If `/usr/local/bin` is not in `PATH`, add it in your shell configuration.
    - If `/usr/local/bin` is in `PATH` but `which nb` returns nothing, continue below.
2. **Check symlink**

```bash
ls -l /usr/local/bin/nb
```

    - If the file does not exist: rerun the baseline and confirm the `file` task that creates the symlink is present and not skipped.
    - If it exists but is not a symlink: remove it and let Ansible recreate it.
3. **Check source**

```bash
ls -ld /usr/local/src/nb
ls /usr/local/src/nb
```

    - If `/usr/local/src/nb` does not exist or is empty: see Scenario B.

### Scenario B: Git clone/update fails

1. **Run the baseline again and watch Git tasks**
    - Use the wrapper script (for example):

```bash
cd ~/projects/infra/t480
scripts/t480-baseline-apply.sh
```

    - Look for errors on the `git` task that clones `nb`.
2. **Common causes**
    - No network / DNS failure.
    - GitHub unreachable or rate-limited.
    - Proxy or firewall blocking outbound HTTPS.
3. **Remediation**
    - Fix network connectivity.
    - If this is for long-term, consider:
        - Mirroring `nb` into a self-hosted Git server (Forgejo).
        - Updating the `git` task `repo` URL to point to the internal mirror.

### Scenario C: `nb` runs but is outdated

1. **Check `nb` version**

```bash
nb version 2>/dev/null || nb --version 2>/dev/null || nb help | head
```

2. **Force an update via Ansible**
    - The Ansible `git` task should have `update: yes`.
    - Run the baseline again; the `git` module will pull the latest commit from the configured branch (e.g. `main`).
3. **Manual check (optional)**

```bash
cd /usr/local/src/nb
git status
git log -1
```

    - Confirm that the repository is clean and at the expected revision.

***

## Design Rationale

- **Vendor-agnostic**: Using upstream Git and `/usr/local/src` avoids lock-in to a specific distro package or third-party package registry.
- **Reproducible**: Ansible manages both the source and the symlink, making installation idempotent.
- **Transparent**: The layout (`/usr/local/src/nb` + `/usr/local/bin/nb`) is standard and easy to inspect during troubleshooting.
- **Extensible**: If you later want to:
    - Mirror `nb` to Forgejo.
    - Pin to a specific tag or commit.
    - Add completion scripts or plugins.

You can extend the Ansible tasks around the same structure without changing how users call `nb`.

***

## Checklist for Future Changes

When modifying `nb` installation in the baseline:

- [ ] Keep `/usr/local/src/nb` as the canonical source location.
- [ ] Keep `/usr/local/bin/nb` as the canonical executable path on `PATH`.
- [ ] Do **not** reintroduce `nb` into any package list.
- [ ] Ensure the `git` task specifies:
    - `repo` (internal or external).
    - `version` (branch, tag, or commit).
    - `update: yes` if automatic updates are desired.
- [ ] Update any validation scripts to:
    - Assert `command -v nb` works.
    - Assert `/usr/local/bin/nb` is a symlink that resolves to an existing file under `/usr/local/src/nb`.
