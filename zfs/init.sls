{# include machine-bootstrap/zfs/custom-zfs.sls
  if zfs:custom-build:enabled: true
  include zfs-auto-snapshot

add packages "zfsutils-linux zfs-dkms" after custom build

arc_max_bytes=$(grep MemTotal /proc/meminfo | awk '{printf("%u",$2*25/100*1024)}')
"use maximum of 25% of available memory for arc zfs_arc_max=$arc_max_bytes bytes"

/etc/modprobe.d/zfs.conf:
    options zfs zfs_vdev_scheduler=cfq
    options zfs zfs_arc_max=${arc_max_bytes}"


+ set scrub non linear, for 6 weeks every 14days on sunday, then twice per year
  + default: Scrub the second Sunday of every month.
  +  24 0 8-14 * * root [ $(date +\%w) -eq 0 ] && [ -x /usr/lib/zfs-linux/scrub ] && /usr/lib/zfs-linux/scrub

+ install, configure zfs-autosnapshot

#}
