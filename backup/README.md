# Backup

Backup using **Restic** to many third party storage types as a systemd service and timer.
+ pre and post- backup **hooks**
+ **automatic housekeeping** of the backupstorage (forget, prune, cleanup)
+ initial backup job can define a different maximum runtime (for already filled servers)
+ **rclone** for additional **third party storage** types
+ **errors and warnings** can be written to **Sentry**
+ **prometheus metrics** available about the backup

## TODO

+ backup-service.sh: finish restic backup call (include, exclude, ...)

## Operation Safety and Security

this state can be used without alerting and metrics tracking,
but for operational security, eg. to get sure that the backup actually sucessfully happend,
and be alerted if not, alerting and metrics tracking should be used.

+ prometheus metrics are written to prom files for pickup.
+ alert tracking is done via sentry, and needs the `gitops` state to be included.
+ additional alerts should be configured via prometheus eg. from
last sucessful backup start timestamp < 25h, to be sure that even if there is no error sent, the absence of the last sucessful metrics, will also trigger an alert.

```yaml
# example alert.rules.yml
group:
- name: backup.alert.rules
  rules:
  - alert: BackupMissed
    expr: (time() / 3600) - (backup_start_timestamp / 3600) > 25
    labels:
      severity: error
    annotations:
      summary: "Backup run missed"
      description: |
        Node did not have a sucessful backup since 25h. Last sucessful backup was at {{ $value }}.
        Backup should run every 24h.
```

## Configuration

+ [defaults.jinja](defaults.jinja)
+ restic, see https://restic.readthedocs.io/en/stable/
+ gitops state, see state [gitops](../gitops)

## Usage

+ Backup can be triggered via systemd timer, or manual via `systemctl start backup`.

+ Restic Backup Maintenance as root can be done using `backup-run.sh restic *`,
which will read the backup user environment change to the user and run restic.

+ create a new restic repository at configured location
    + `$0 restic init`

+ activate an existing repository for backup
    + `set_tag "backup/backup_repo_id" "$($0 restic cat config --json | json_dict_get id)"`

## Tags set and recognized

will use backup.var_dir/tags, or gitops.var_dir/tags if gitops state is included.

+ `backup_repo_id`
+ `backup_housekeeping_timestamp`
+ `backup_initial_start_timestamp`
+ `backup_initial_end_timestamp`

## Prometheus Metrics

output will be written to backup.var_dir/metrics, or to gitops.var_dir/metrics if gitops state is included.

+ `backup_start_timestamp` counter "The start of the last sucessful backup run as timestamp-epoch-seconds"
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
+ `backup_stats_local_duration_sec` gauge "The duration in number of seconds of the backup local stats run"

### Sentry Messages

to use sentry reporting, add and configure
```
include:
  - gitops
```
if gitops state is not included, sentry entries will be printed to stdout but not send.


+ warning
  + `App Backup` "backup warning: cache --cleanup returned error"
  + `App Backup` "backup warning: stats returned error"

+ error
  + `App Backup` "backup error: repository id at $(get_tag_fullpath backup/backup_repo_id) is missing or invalid."
  + `App Backup` "backup error: could not get repository id from remote"
  + `App Backup` "backup error: repository id missmatch"
  + `App Backup` "backup error: backup failed with error $err"
  + `App Backup` "backup error: forget returned error"
  + `App Backup` "backup error: prune returned error"
  + `App Backup` "backup error: repository check returned error"
