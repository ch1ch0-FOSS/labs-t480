# T480 Golden State v1.0: 
- Eplicit List 

## Packages 

**CORE RHEL/Fedora Admin stack:** 

* Bash, coreutils, util-linux, grep, sed, awk, findutils 
* iproute / iproute2, iputils,
* NetworkManager, 
* systemd tools: systemd, systemd-udev, systemd-resolved 
* dnf, dnf-plugins-core 
* openssh-clients, openssh-server
* SELinux userspace: libselinux-utils, policycoreutils, policycoreutils-python-utils, setools-console

### Vi-centric workflow:

* vim (set up for wayland)
* tmux (set up for wayland) 
* foot (wayland native) 
* vimb, w3m, ddgr - Web browsing 
* wl-clipboard, wl-copy, wl-paste

### Infra/LIPC/RHEL tooling

* git
* gnustow (dotfile management, symlinks)
* ansible-core
* chrony 
* sysstat 
* lvm2, xfsprogs 
* tcpdump, mmap + ncat, nmap 
* podman 

### VM/ virtualization stack (RHEL-style)

* qemu-kvm
* libvirt, libvirt-daemon, libvirt-daemon-config-network
* virt-install

### Sync and connectivity 

* syncthing
* tailscale

### Misc. 

* rsync, 
* tar, xz, gzip, bzip2 
* curl, wget
* nb
* navi 

## Quality-of-life 
* Caps Lock mapped to Escape

## Services and polices (v1)

### Enable and configure 

* firewalld 
- default-zone: public, allow ssh service 

* sshd 
- permitbootlogin no 
- passwordauthentication allowed (keys preferred) 

* chronyd 
- enabled and synced to reasonable NTP sources 

* libvirtd 
- enabled and running for local KVM 

* syncthing 
- user-level service, configured to sync PKM/data/media with srv-m1m and Pixel 

* tailscaled 
- enabled on T480 and Pixel to reach lab hosts over Tailscale when needed 

* SELinux 
- mode enforcing 
- Type: targeted policy 
- Ensure setenforce 1 and /etc/selinux/config both reflect enforcing 

* SSH policy 
- Root SSH login disabled 
- User in wheel with sudo rights 
- Key-based auth configured, password auth 

* Firewall policy 
* Inbound: ssh only 
* Outbound: default allow 

## VM stack (v1) 

* Hypervisor and tools 
- KVM + libvirt as above 
- Default libvirt network (virbr0) active 

* Usage expectations 
- 1 RHEL/Fedora VM for LPIC/RHCSA practice 
- VM creation and management are done via virt-install/virsh  
- Document VM process, Setup for LPIC/RHCSA labs and exam practice 
