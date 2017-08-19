# Knot DNS server salt-stack

+ pillar: knot
  + relaxed (order does not matter) knot.conf yaml with some additions
  + active: true,false
  + logging: if empty will use defaults.jinja:log_default
  + zone:
    + source: salt source file which gets copied to default file target for zone
      + you can use jinja templating within

+ TODO:
  + check zone files before udpate
  + warning: cannot open persistent timers DB (not exists)
  + error: [121.168.192.in-addr.arpa] DNSSEC, failed to initialize (not found)
  + error: [121.168.192.in-addr.arpa] failed to store changes into journal (not found)
  + knot{{ '' if grains['osrelease_info'][0] < 16 else '.service' }}