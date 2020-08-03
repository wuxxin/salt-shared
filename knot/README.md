# Knot DNS server

+ pillar
    + relaxed (does not matter) order of knot.conf yaml
    + set pillar['knot:enabled']= false to disable a configured knot
    + configure additional knot instances
        + add pillar 'knot:profile:[{'name': 'xxx',}]'

+ zone source files
    + automatic check of zone files before udpate of files
    + salt source file which gets copied to default file target for zone
    + jinja templating in source file with prefilled context var
        + common.* from defaults.jinja
        + custom additional context vars: add context data to zone

+ logging: if empty will use defaults.jinja:log_default
+ examples: see example.pillar.yaml, example.zone.jinja

+ secrets
    + Warning: key:secret (hmac-sha256) must generated as 256bit base64 encoded
    + eg. `openssl rand -base64 32`
    + eg. `keymgr -t test hmac-sha256 256`

+ Default Server
    + use pillar "knot"

+ Additional Server
    + one per pillar list: "knot:profile:[{'name': 'profilename', }]"
