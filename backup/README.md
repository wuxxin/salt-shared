# Backup

Backup using Restic to many third party storage types as a systemd service and timer.
+ pre and post- backup hooks
+ configurable storage size
+ automatic housekeeping for the backupstorage with prunning requested oldest changes
+ initial backup job can define a different maximum runtime (already filled servers)
+ rclone for additional third party storage types
+ errors and warnings written to Sentry
+ prometheus metrics about the backup

## Configuration

## Execution

Can be triggered viasystemd timer, or manual via `systemctl start backup`.

### Tags set and recognized

will use directory gitops gitops.var_dir/tags if included: gitops, else backup.tag_dir for storage

+ `app_backup_id`

### Prometheus Metrics

to use prometheus metrics, include: gitops, if not included, metrics will be printed to stdout

+ `backup_start_timestamp` counter "The start of the last backup run as timestamp-epoch-seconds"
+ `backup_duration_sec` gauge "The duration in number of seconds of the last backup run"
+ `backup_used_size_kb` gauge "The number of kilo-bytes used in the backup space"
+ `backup_data_size_kb` gauge "The sum of the local filesizes of the backuped files in kilo-bytes"
+ `backup_config_duration_sec` gauge "The duration in number of seconds of the backup config run"
+ `backup_pre_hook_{{ hook.name }}_duration_sec` gauge "Duration for {{ hook.description|d(hook.name) }}"
+ `backup_backup_duration_sec` gauge "The duration in number of seconds of the actual backup run"
+ `backup_post_hook_{{ hook.name }}_duration_sec` gauge "Duration for {{ hook.description|d(hook.name) }}"
+ `backup_forget_duration_sec` gauge "The duration in number of seconds of the backup forget run"
+ `backup_prune_duration_sec` gauge "The duration in number of seconds of the backup prune run"
+ `backup_check_duration_sec` gauge "The duration in number of seconds of the backup check run"
+ `backup_cleanup_duration_sec` gauge "The duration in number of seconds of the backup cleanup run"
+ `backup_stats_duration_sec` gauge "The duration in number of seconds of the backup stats run"

### Sentry Messages

to use sentry reporting, include: gitops, if not included, sentry entries will be printed to stdout

+ warning
  + `App Backup` "backup warning: cache --cleanup returned error"
  + `App Backup` "backup warning: stats returned error"

+ error
  + `App Backup` "backup error: repository id at $(get_tag_fullpath app_backup_id) is missing or invalid.""
  + `App Backup` "backup error: could not get repository id from remote"
  + `App Backup` "backup error: repository id missmatch"
  + `App Backup` "backup error: backup failed with error $err"
  + `App Backup` "backup error: forget returned error"
  + `App Backup` "backup error: prune returned error"
  + `App Backup` "backup error: repository check returned error"
