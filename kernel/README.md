# kernel

+ state: kernel
  + install matching kernel-image, headers and tools, depending os-version.
  + "kernel:keep_current:True" (default=False) or instance running on LXC
      + only install a matching kernel- headers and tools of the running kernel

+ state: kernel.server: big setup (lot of open files, connections, ...)
  + kernel.running-headers
  + kernel.sysctl
  + kernel.cgroup
  + kernel.limits
  + kernel.module
    + kernel.module.netfilter
    + kernel.module.overlay
  + kernel.swappiness

+ state: kernel.entropy
  + installs haveged

+ state: power
  + installs acpid
