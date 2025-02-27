# nfs state

+ nfs version 4 only
+ restricted to localhost ipv4/ipv6 port 2049
+ disabled rpcbind
+ add custom listen ip's by overwriting the default list in `nfs:listen_ip`
    + be sure to include '127.0.0.1' and '::1' in the list

```yaml
nfs:
  listen_ip:
    - '127.0.0.1'
    - '::1'
    - '1.2.3.4.5'
    - '6.7.8.9.0'
```

+ notes

```
+ sysctl
('fs.nfs.nfs_callback_tcpport', 32764),
('fs.nfs.nlm_tcpport', 32768),
('fs.nfs.nlm_udpport', 32768),]
+ /usr/lib/systemd/scripts/nfs-utils_env.sh creates /run/sysconfig/nfs-utils
+ /etc/default/nfs-common
  + rpc.statd: --no-notify $STATDARGS=\"$STATDOPTS\"
+ /etc/default/nfs-kernel-server
  + rpc.nfsd: RPCNFSDARGS=\"$RPCNFSDOPTS ${RPCNFSDCOUNT:-8}\"
  + rpc.mountd: $RPCMOUNTDARGS=\"$RPCMOUNTDOPTS\"
  + rpc.svcgssd: $SVCGSSDARGS=\"$RPCSVCGSSDOPTS\"
+ supported but not exposed from nfs-utils_env.sh:
  + sm-notify: SMNOTIFYARGS=\"$SMNOTIFYARGS\"
  + rpc.idmapd: RPCIDMAPDARGS=\"$RPCIDMAPDARGS\"
  + blkmapd: BLKMAPDARGS=\"$BLKMAPDARGS\"
+ uses tcp_wrapper for access control
  + /etc/hosts.deny:
    rpcbind mountd nfsd statd lockd rquotad portmap: ALL
  + /etc/hosts.allow:
    rpcbind mountd nfsd statd lockd rquotad portmap: 127.0.0.1/24
    # only for IP 192.168.1.13: portmap: 192.168.1.13
    # for whole lan: portmap: 192.168.1. or portmap: 192.168.1.0/24
```
