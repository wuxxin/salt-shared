# Knot DNS server

+ knot config in pillar
    + **relaxed order** (does not matter) of knot.conf yaml
    + set pillar['knot:enabled']= false to disable a configured knot

+ **multiple instances**: configure additional knot instances
        + "knot:profile:[{'name': 'profilename', }]"

+ zone source files
    + **zone serial** is **automatically handled** by knot, serial-policy: unixtime
    + knot is configured to **not touch source zone files** and use journal for changes and dnssec
    + zone source can be **inline in pillar** or a salt **source file with templating**
    + jinja templating with **prefilled variable context** can be used
        + use common.* for vars from defaults.jinja
        + define custom vars by adding to zone[{context: {a: b}}

+ **updates** to config or zone files **are validated**
    before applying against "knotc conf-check" and "kzonecheck",
    and should not interrupt current connections on update

+ default template config: see defaults.jinja:template_default
+ default logging: if empty will use defaults.jinja:log_default
+ examples: see example.pillar.yaml, example.zone.jinja

+ howto generate DNS secrets
    + secret (hmac-sha256) must generated as 256bit base64 encoded characters
    + eg. `openssl rand -base64 32`
    + eg. `keymgr -t test hmac-sha256 256`
