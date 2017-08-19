# Knot DNS server salt-stack

+ Feature: use more than one knot instance

+ knot:instance:[].id = 'default' # normal default instance (/etc/knot/knot.conf)

+ knot:instance:[array]
  + an array of normal knot.conf yaml with some additions:
    + id: id of server
    + active: true,false
    + logging: if empty will use defaults.jinja:log_default
    + zone:
      + source: salt source file which gets copied to default file target for zone
        + you can use jinja templating within

+ drawbacks: currently there is no module config support (mod-modulename section)

+ TODO:
  + check zone files before udpate
  + warning: cannot open persistent timers DB (not exists)
  + error: [121.168.192.in-addr.arpa] DNSSEC, failed to initialize (not found)
  + error: [121.168.192.in-addr.arpa] failed to store changes into journal (not found)