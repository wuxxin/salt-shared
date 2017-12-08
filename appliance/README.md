# appliance state

## hooks

Every executable hook script will get executed in sorted order.
add hook scripts to: `/app/etc/hooks/{subsystem}/{hookname}/*`

### Available Hooks

+ `/appliance-backup/`
    + prefix_mount
    + postfix_mount
    + prefix_cleanup
    + prefix_backup
    + prefix_purge
    + prefix_unmount
    + postfix_unmount

## flags

+ basedir: `/app/etc/flags/`
    + metric.exporter
    + metric.server
    + metric.gui
    + no.node-exporter
    + no.cadvisor
    + no.prometheus
    + no.grafana
    + no.process-exporter
    + no.alertmanager
    + no.postgres_exporter

## generate a new pillar env with secrets

scripts/env-create.sh
