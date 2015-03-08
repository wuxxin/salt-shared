linux-image:
  pkg.installed:
    - pkgs:
      - linux-image-generic
      - linux-image-generic-lts-utopic
      - linux-image-extra-virtual
      - linux-image-extra-virtual-lts-utopic

linux-image-latest:
  pkg.installed:
    - sources:
      - "linux-headers-3.19.1-031901": "http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.19.1-vivid/linux-headers-3.19.1-031901_3.19.1-031901.201503080052_all.deb"
      - "linux-headers-3.19.1-031901-generic": "http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.19.1-vivid/linux-headers-3.19.1-031901-generic_3.19.1-031901.201503080052_amd64.deb"
      - "linux-image-3.19.1-031901-generic": "http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.19.1-vivid/linux-image-3.19.1-031901-generic_3.19.1-031901.201503080052_amd64.deb"
