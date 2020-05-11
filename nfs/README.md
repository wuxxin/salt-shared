# nfs state

+ default is nfs version 4 only
  + restricted to localhost ipv4/ipv6 port 2049
  + disabled rpcbind

+ add custom listen ip's by overwriting the default list in `nfs:listen_ip`
    + be sure to include '127.0.0.1' and '::1' in the list

eg.
```
nfs:
  listen_ip:
    - '127.0.0.1'
    - '::1'
    - '1.2.3.4.5'
    - '6.7.8.9.0'
```

+ nfs version 3 support can be enabled in pillar `nfs:legacy_support:true`
  + warning: still opens some ports to any, config needs some adjustments
