# Knot DNS server

+ pillar
    + relaxed order (does not matter) of knot.conf yaml
    + to disable a configured knot, set pillar['knot:enabled']= false
+ zone source files
    + automatic check of zone files before udpate of files
    + salt source file which gets copied to default file target for zone
    + jinja templating in source file with prefilled context var
        + common.* from defaults.jinja
        + autoserial (YYMMDDHHMM) (conditions: one change per minute max, breaks in year 2100)
        + custom additional context vars: add context data to zone
+ logging: if empty will use defaults.jinja:log_default
+ example: example.pillar, example.zone

## System DNS

+ uses pillar "knot"

## Container DNS

+ uses podman and systemd service and pillar "container:knot" instead of "knot"
+ set "container:knot:name" as container and systemd service name
  + defaults to "container_knot"
