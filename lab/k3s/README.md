# k3s

+ also look at
    + https://github.com/opencontainers/runc
    + https://github.com/containerd/containerd

+ kernel modules to be loaded at start:
```
overlay
br_netfilter
nf_conntrack
ip_vs
ip_vs_rr
ip_vs_wrr 
ip_vs_sh
```

## errors

+ [kubelet.go:1327] Failed to start ContainerManager failed to get rootfs info: cannot find filesystem info for device "rpool/data/lxd/containers/k3"
    + add zfs devices (FIXME: is unsafe, but k3s needs it for fsinfo /)

+ [cri_stats_provider.go:375] Failed to get the info of the filesystem with mountpoint "/var/lib/rancher/k3s/agent/containerd/io.containerd.snapshotter.v1.overlayfs": unable to find data in memory cache.

+ [manager.go:326] Could not configure a source for OOM detection, disabling OOM events: open /dev/kmsg: no such file or directory

+ write /proc/self/oom_score_adj: permission denied
+ open /proc/sys/net/bridge/bridge-nf-call-iptables: no such file

+ [controller.go:194] failed to get node "s3" when trying to set owner ref to the node lease: nodes "s3" not found

## install

+ install helm: `helm init --upgrade --service-account tiller`
 