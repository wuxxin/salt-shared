# kernel

install matching kernel-package, headers and tools, depending os-version.

+ to install a manual kernel from the web: 
    + set "kernel.manual_download: True "
+ to keep state.kernel from modifying the kernel-image
    + set pillar item: "kernel.keep_current: True"
