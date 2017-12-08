# appliance state

## hooks

Every executable hook script will get executed in sorted order.
add hook scripts to: `/app/etc/hooks/{subsystem}/{hookname}/*`

### Available Hooks

+ `appliance-backup`
    + prefix_mount
    + postfix_mount
    + prefix_cleanup
    + prefix_backup
    + prefix_purge
    + prefix_unmount
    + postfix_unmount

+ `appliance-prepare`
    + start
    + 
## flags

+ basedir: `/app/etc/flags/`

+ metric system flags
    + metric.exporter
    + metric.server
    + metric.gui
    
    + no.alertmanager
    + no.cadvisor
    + no.grafana
    + no.node-exporter
    + no.postgres_exporter
    + no.process-exporter
    + no.prometheus

+ update system flags, will be deleted after update execution
    + force.update.appliance
    + force.update.compose
    + force.update.docker
    + force.update.letsencrypt
    + force.update.postgres
    + force.update.system

## generate a new pillar env with secrets

scripts/env-create.sh
