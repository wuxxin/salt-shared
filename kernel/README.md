# kernel

### state: kernel
+ install matching kernel-image, headers and tools, depending os-version.
+ if "kernel:keep_current:True" (default=False)
  or if instance running on shared kernel (eg. LXC, LXD, NSPAWN)
      + install only matching kernel- headers and tools of the running kernel

### state: kernel.server
+ big setup, many open files, connections...
+ kernel.running
    + make kernel headers of running kernel available, in case dkms modules need them
+ kernel.cgroup
    + set cgroup v2 only hierachy
    + allow normal users to run unprivileged containers
+ systemd.cgroup-accounting
    + activate cgroup (cpu, task, memory, io) accounting
+ kernel.swappiness
    + configure swap usage, defaults to kernel default
+ kernel.limits
    + expand max open files
+ kernel.sysctl
    + expand max for kernel keys, inotify entries, memory mapped areas, ipv4 and ipv6 arp cache, tcp bbr congestion control
+ kernel.module
    + activate typical used netfilter kernel modules
    + activate and configure kernel overlay fs module

### state: kernel.oomd
+ install advanced out of memory managment userspace daemon
    + needs cgroup v2 and systemd accounting

### state: kernel.entropy
+ installs haveged, for feeding additional entropy to kernel

### state: power
+ installs acpid, for power button functionality
