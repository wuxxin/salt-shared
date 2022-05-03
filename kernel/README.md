# kernel

## state: kernel

install matching kernel-image, headers and tools, depending os-version

+ if "kernel:keep_current:True" (default=False) or
    if instance running on shared kernel (eg. LXC, LXD, NSPAWN):
    + install only matching kernel- headers and tools of the running kernel

## state: kernel.server

server setup; many open files, network connections, processes, containers, etc.

+ kernel.running
    + make kernel headers of running kernel available, in case dkms modules need them
+ kernel.swappiness
    + configure swap usage, defaults to kernel default, for details read swappiness.sls
+ kernel.limits
    + increase maximum open files, maximum locked-in-memory address space
+ kernel.sysctl
    + expand max for kernel keys, inotify entries, memory mapped areas, ipv4 and ipv6 arp cache
    + cgroup: allow normal users to run unprivileged containers
    + not included by default: sysctl.tcp-bbr
+ kernel.lxc
    + install cgroup tools and support files for lxc powered virtualization
+ kernel.nfs
+ kernel.network
    + activate typical used network kernel modules, install helper utilities
+ systemd.cgroup
    + set cgroup v2 only hierachy managed by systemd
    + activate cgroup (cpu, task, memory, io) accounting

## optional states not included in kernel.server

### state: kernel.entropy
+ if older distro (ubuntu <20.04, debian<10) install haveged for feeding additional entropy to kernel

### state: sysctl.tcp-bbr
+ install tcp bbr congestion control instead of kernel default (usually cubic)
    + see url links in tcp-bbr.sls for insights about bbr

### state: kernel.oomd
+ install advanced out of memory managment userspace daemon
    + needs cgroup v2 and systemd accounting
