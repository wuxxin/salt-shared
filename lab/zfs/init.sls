
+ set scrub non linear, for 6 weeks every 14days on sunday, then twice per year
  + default: Scrub the second Sunday of every month.
  +  24 0 8-14 * * root [ $(date +\%w) -eq 0 ] && [ -x /usr/lib/zfs-linux/scrub ] && /usr/lib/zfs-linux/scrub

+ install, configure zfs-autosnapshot
