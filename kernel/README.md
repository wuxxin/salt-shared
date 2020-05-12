# kernel

+ state: kernel
  + install matching kernel-package, headers and tools, depending os-version.
  + pillar item: "kernel:keep_current:True" (default=False) or instance running on LXC
      + only install a matching kernel-tools and headers to the running kernel

+ state: kernel.server: big setup (lot of open files, connections, ...)
  + kernel.sysctl
  + kernel.cgroup
  + kernel.limits
  + kernel.module
    + kernel.module.netfilter
    + kernel.module.overlay
  + kernel.swappiness
  + kernel overlay fs

+ state: kernel.entropy
  + installs haveged

+ state: power
  + installs acpid
