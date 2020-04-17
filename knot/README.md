# Knot DNS server

+ pillar: relaxed (order does not matter) knot.conf yaml 
    + to disable a configured knot, set pillar['knot:enabled']= false
+ automatic check of zone files before udpate of files
+ logging: if empty will use defaults.jinja:log_default
+ zone source files
    + salt source file which gets copied to default file target for zone
    + jinja templating in source file
    + prefilled context:
        + common.* from defaults.jinja
        + autoserial (YYMMDDHHMM)
            + conditions: one change per minute max, breaks in year 2100
    + additional custom context:
        + add context: data to zone
+ example: example.pillar, example.zone
