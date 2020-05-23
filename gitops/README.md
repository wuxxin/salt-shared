# Gitops State

+ flags recognized
  + failed.gitops.update
  + force.gitops.update
  + disable.gitops.update
  + disable.automatic.reboot

+ tags recognized
  + gitops_failed_rev
  + gitops_current_rev

+ metric written
  + ssl_cert_valid_until gauge "timestamp of certificate validity end date"
  + update_start_timestamp counter "timestamp-epoch-seconds since last update to app"
  + update_duration_sec gauge "number of seconds for a update run"
  + update_reboot_timestamp counter "timestamp-epoch-seconds since update requested reboot"
