# appliance state


## hooks

Every executable hook script will get executed in sorted order.
add hook scripts to: `/app/etc/hooks/{subsystem}/{hookname}/*`

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

