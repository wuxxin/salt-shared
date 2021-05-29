# Gitops State

## bootstrap a gitops install

```sh
/path/to/create-gitops-repo.sh ~/work mymachine \
    git.server.domain gituser user@email mymachine.domain.name --no-remote
```

## Flags, Tags, Metrics, Sentry Messages

### Flags recognized

+ `gitops.update.failed`
+ `gitops.update.disable`
+ `gitops.update.force`
+ `reboot.automatic.disable`

### Tags recognized

+ `gitops_failed_rev`
+ `gitops_current_rev`

### Prometheus Metrics

+ `update_start_timestamp` counter "timestamp-epoch-seconds since last update to app"
+ `update_duration_sec` gauge "number of seconds for a update run"
+ `update_reboot_timestamp` counter "timestamp-epoch-seconds since update requested reboot"
+ `ssl_cert_valid_until` gauge "timestamp of certificate validity end date"

### Sentry Messages

+ info
  + "Gitops Execution" "Frontend Ready"
+ warning
  + "SSL warning" "Certificate for $subject_cn is less than $min_days days valid\nValidity end date=$valid_until"
+ error
  + "Gitops Attention" "node needs reboot, human attention required"
  + "Gitops Error" "(validate_cmd|before_cmd|update_cmd|after_cmd|finish_cmd) failed with error $result"
  + "SSL error" "Certificate for $subject_cn is less than $min_days days valid\nValidity end date=$valid_until"
  + "Service Error" "Service ($UNITNAME) failed" "$(unit_json_status)"

## Update Execution

Can be triggered via webhook, systemd timer, or manual via `systemctl start gitops-update`.
Execute the following steps, any step that fails stops executing later steps:

+ `validate`: check the syntactical validity of the update, must not interrupt services!
+ `before`: executed before "update", may stop services that may get restarted on finish
+ `update`: the acutal update command
+ `after`: executed after "update" did run sucessful, eg. for metric processing
+ `finish`: is executed after "after" was sucessful and machine does not need a reboot
            eg. to restart services that got stopped

Example:
```yaml
update:
  before_cmd: /usr/bin/systemctl stop xyz
  after_cmd: /usr/bin/bash '. /usr/local/lib/gitops-library.sh; simple_metric test_update_run counter "timestamp of update run" "$(date +%s)"'
  finish_cmd: /usr/bin/systemctl start --no-block xyz
```
