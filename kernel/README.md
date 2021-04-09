# kernel

## TODO

+ https://wiki.archlinux.org/index.php/Talk:Sysctl
+ https://blog.cloudflare.com/path-mtu-discovery-in-practice/
+ https://blog.cloudflare.com/the-story-of-one-latency-spike/
+ https://nateware.com/2013/04/06/linux-network-tuning-for-2013/

### state: kernel
+ install matching kernel-image, headers and tools, depending os-version
+ if "kernel:keep_current:True" (default=False) or
    if instance running on shared kernel (eg. LXC, LXD, NSPAWN):
    + install only matching kernel- headers and tools of the running kernel

### state: kernel.server
+ target: big machine setup, many open files, network connections, processes, containers, etc.

+ kernel.running
    + make kernel headers of running kernel available, in case dkms modules need them
+ kernel.cgroup
    + set cgroup v2 only hierachy managed by systemd
    + allow normal users to run unprivileged containers
+ systemd.cgroup-accounting
    + activate cgroup (cpu, task, memory, io) accounting
+ kernel.swappiness
    + configure swap usage, defaults to kernel default, for details read swappiness.sls
+ kernel.limits
    + expand max open files
+ kernel.sysctl
    + expand max for kernel keys, inotify entries, memory mapped areas, ipv4 and ipv6 arp cache
    + not included by default: sysctl.tcp-bbr
+ kernel.module
    + activate typical used network kernel modules
    + activate and configure kernel overlay fs module
+ kernel.kvm
    + install qemu and all support files for kvm powered virtualization

### state: sysctl.tcp-bbr
+ install tcp bbr congestion control instead of kernel default (usually cubic)
    + see url links in tcp-bbr.sls for insights about bbr

### state: kernel.oomd
+ install advanced out of memory managment userspace daemon
    + needs cgroup v2 and systemd accounting

### state: kernel.entropy
+ installs haveged, for feeding additional entropy to kernel

### state: power
+ installs acpid, for power button functionality
