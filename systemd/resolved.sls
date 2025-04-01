# add stub listener for resolved on ipv6 loopback

/etc/systemd/resolved.conf.d/localhostipv6.conf:
  file.managed:
    - makedirs: true
    - contents: |
        [Resolve]
        DNSStubListenerExtra=[::1]:53
