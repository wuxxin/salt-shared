# Containerd

+ containerd + cni + nerdctl

+ can be used
  + as external containerd for k3s, making zfs for k3s support possible
  + as rootfull docker compatible cli using containerd + nerdctl
  + as rootless docker compatible cli using containerd user service + nerdctl

- Storage Drivers:
  - "overlay":
    - CONFIG_OVERLAY_FS: enabled (as module)

## TODO

+ FIXME: /etc/containerd/config.toml is not working if empty but with filled default
+ CHECK:
  + CONFIG_RT_GROUP_SCHED: missing
  + CONFIG_INET_XFRM_MODE_TRANSPORT: missing
