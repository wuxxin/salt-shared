# Knot DNS server

+ pillar: knot
  + relaxed (order does not matter) knot.conf yaml 
  + automatic check of zone files before udpate of files
  + to disable a configured knot, set pillar['knot:enabled']= false
  + logging: if empty will use defaults.jinja:log_default
  + zone:source: salt source file which gets copied to default file target for zone
        + you can use jinja templating in source file
