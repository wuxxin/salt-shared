# kernel

install matching kernel-package, headers and tools, depending os-version.

+ will install the "virtual" flavor if running as virtual machine
+ will only install matching kernel-tools on LXC
 
+ pillar item: "kernel:package:keep_current:True" (default=False)
    + keep state.kernel from modifying or installing a kernel-image
    + will only install a matching kernel-tools to the running kernel

+ pillar item: "kernel:package:no_extra:True" (default=False)
    + do not install kernel-image-extra
