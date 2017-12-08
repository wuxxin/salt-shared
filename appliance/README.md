# appliance state


## hooks

Every executable hook script will get executed in sorted order.
add hook scripts to: `/app/etc/hooks/{subsystem}/{hookname}/*`

### additional honoured flags

metric.exporter
metric.server
metric.gui
no.node-exporter
no.cadvisor
no.prometheus
no.grafana
no.process-exporter
no.alertmanager
no.postgres_exporter


### Available Hooks

+ `/appliance-backup/`
    + postfix_config
    + postfix_mount
    + postfix_unmount
    + prefix_backup
    + prefix_cleanup
    + prefix_config
    + prefix_mount
    + prefix_purge
    + prefix_unmount


### generate a new pillar env with secrets

scripts/env-create.sh
