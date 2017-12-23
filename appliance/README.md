# appliance state

## Features

+ unattended install
+ seperate build and configure
+ environment configuration from file via ENV_YML, pillar, /app/env.yml, cidata or config-2 labed drive, aws-ec2 or gce meta-data server
+ unattended update of salstack states, system, docker, compose, a.o.
+ unattended backup of important data
+ plugin support for extending appliance
+ optional metric support
+ optional alerting support (sentry)

## pillar/environment template

+ see env-template.sls

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
    + create_backup_filelist | every plugin must return a globfile list on stdout

+ `appliance-prepare`
    + start

+ `appliance-update`
    + check   | every plugin must return a update list on stdout
              | lines beginning with "#" are ignored
              | syntax is: updatehookfile:updatename=[args]
              | special "#%need_service_restart=true" restarts service after update
    + update  | only plugins listed on check get executed
              | and called using $0 update_function [args]

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
