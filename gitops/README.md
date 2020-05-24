# Gitops State

+ flags recognized
  + gitops.update.failed
  + gitops.update.force
  + gitops.update.disable
  + reboot.automatic.disable

+ tags recognized
  + gitops_failed_rev
  + gitops_current_rev

+ metric written
  + ssl_cert_valid_until gauge "timestamp of certificate validity end date"
  + update_start_timestamp counter "timestamp-epoch-seconds since last update to app"
  + update_duration_sec gauge "number of seconds for a update run"
  + update_reboot_timestamp counter "timestamp-epoch-seconds since update requested reboot"

+ sentry entries
  + "SSL ${issue}" "Certificate for $subject_cn is less than $min_days days valid\nValidity end date=$valid_until\n" "$issue"
  + "Gitops Execution" "Frontend Ready" "info"
  + "Gitops Attention" "node needs reboot, human attention required" "error"
  + "Gitops Error" - Level Error
    + "pre_update_command failed with error $result"
    + "update command failed with error $result"
    + "post_update_command failed with error $result"
    + "finish_update_command failed with error $result"
