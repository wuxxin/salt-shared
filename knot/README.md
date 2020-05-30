# Knot DNS server

+ pillar
    + relaxed order (does not matter) of knot.conf yaml
    + to disable a configured knot, set pillar['knot:enabled']= false
    + additional knot instances, add pillar 'knot:profile:[{'name': 'xxx',}]'
+ zone source files
    + automatic check of zone files before udpate of files
    + salt source file which gets copied to default file target for zone
    + jinja templating in source file with prefilled context var
        + common.* from defaults.jinja
        + custom additional context vars: add context data to zone
+ logging: if empty will use defaults.jinja:log_default
+ example: example.pillar.yaml, example.zone.jinja

## Secrets

Warning: key:secret must be encoded with
  salt['hashutil.base64_b64encode'](secret)
## Default Server

+ uses pillar "knot"

## Additional Server

+ one per pillar list: "knot:profile:[{'name': 'profilename', }]"
