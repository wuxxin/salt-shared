# entropy gathering daemon, useful for virtual/headless machines

{#
Starting from Linux kernel v5.6, the HAVEGED service has become obsolete.

The mainline Linux Kernel has now HAVEGED algorithm build in internally.
See https://lore.kernel.org/lkml/alpine.DEB.2.21.1909290010500.2636@nanos.tec.linutronix.de/T/

Furthermore, as soon as the CRNG (the Linux cryptographic-strength random
number generator) gets ready, /dev/random does not block on reads anymore.
See the kernel commit https://github.com/torvalds/linux/commit/30c08efec8884fb106b8e57094baa51bb4c44e32

+ ubuntu < focal (20.04) have kernel < 5.6
+ ubuntu = focal (20.04) has 5.4 mainline, and 5.8 HWE kernel
+ ubuntu > focal (20.04) have kernel > 5.6
+ debian < buster (10) have kernel < 5.6
+ debian = buster (10) has 4.19 mainline, and 5.10 backports kernel
+ debian > buster (10) have kernel > 5.6

#}

haveged:
  pkg:
    - installed
  service.running:
    - enable: True
    - require:
      - pkg: haveged
