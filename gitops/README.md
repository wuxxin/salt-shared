# Gitops State

Service and tools for bootstraping and updating software from git repositories.

+ **templating** of new **gitops repositories** with `create-gitops-repo.sh`
+ secure **bootstraping** execution from **git repositories**
  + using `from-git.sh` and `execute-saltstack.sh`
  + private git repositories accessable by ssh key
  + git-crypt encrypted repositories
+ timer, webhook and direct calling of a **git repository** based **update service**
    + defaults to saltstack as update state reconciler
    + errors and warnings are written to Sentry
    + prometheus metrics about the update
    + https webhook support in combination with state `http_frontend`
+ support for **interactive remote tinker** with `remote-doctor.sh` by syncing local working tree changes to the remote on demand
+ **standalone one file saltstack execution** with salt-shared included
+ part of **machine-bootstrap**'s optional **devop installation** step

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [create a gitops repository](#create-a-gitops-repository)
- [bootstrap from a gitops repository](#bootstrap-from-a-gitops-repository)
- [one shot saltstack template, no repository execution](#one-shot-saltstack-template-no-repository-execution)
- [interactive remote tinker](#interactive-remote-tinker)
- [gitops repository based Update System](#gitops-repository-based-update-system)
	- [Execution](#execution)
	- [Flags set and recognized](#flags-set-and-recognized)
	- [Tags set and recognized](#tags-set-and-recognized)
	- [Prometheus Metrics](#prometheus-metrics)
	- [Sentry Messages](#sentry-messages)

<!-- /TOC -->

## create a gitops repository

```sh
/path/to/create-gitops-repo.sh ~/work mymachine \
    git.server.domain gituser user@email mymachine.domain.name --no-remote
```

## bootstrap from a gitops repository

```sh
target_domain=""; ssh_id=""; gpg_id=""; ssh_known_hosts=""; http_proxy=""
gitops_source=""; gitops_branch=""; gitops_user=""; gitops_target=""; base_name=""
from_git="https://raw.githubusercontent.com/wuxxin/salt-shared/master/gitops/from-git.sh"
# copy script to target
curl "$from_git" > /tmp/from-git.sh
scp /tmp/from-git.sh ssh://$target_domain/tmp/from-git.sh
# pipe ssh_id, gpg_id and ssh_known_hosts to ssh on target and execute script there
printf "%s\n%s\n%s\n" "$ssh_id" "$gpg_id" "$ssh_known_hosts" | \
    ssh ssh://$target_domain "
        chmod +x /tmp/from-git.sh &&
        http_proxy=\"$http_proxy\" && export http_proxy &&
        /tmp/from-git.sh bootstrap \
            --url \"$gitops_source\" \
            --branch \"${gitops_branch:-master}\" \
            --user \"$gitops_user\" \
            --home \"$gitops_target\" \
            --git-dir \"${gitops_target}/${base_name}\" \
            --keys-from-stdin && \
        ${gitops_target}/${base_name}/salt/salt-shared/gitops/execute-saltstack.sh \
            --minion-etc run ${gitops_target}/${base_name} \
            state.highstate
        "
```


## one shot saltstack template, no repository execution

+ execute on target

```sh
#!/bin/sh
set -eo pipefail
self_path=$(dirname "$(readlink -e "$0")")
if test "$1" != "--yes"; then
    echo "Usage: $0 --yes [salt-call param, default=state.highstate]"; exit 1
fi
shift; args="$@"; if test "$args" = ""; then args="state.highstate"; fi
if ! which git > /dev/null; then DEBIAN_FRONTEND=noninteractive apt-get install -y git; fi
mkdir -p $self_path/run $self_path/salt/local $self_path/config
git -C $self_path/salt clone https://github.com/wuxxin/salt-shared.git
printf "base:\n  '*':\n    - main\n" > $self_path/salt/local/top.sls
printf "base:\n  '*':\n    - main\n" > $self_path/config/top.sls
cat > $self_path/config/main.sls << EOF
# pillar

EOF
cat > $self_path/salt/local/main.sls << EOF
# states

EOF
exec $self_path/salt/salt-shared/gitops/execute-saltstack.sh \
      --minion-etc run $self_path "$args"
```


## interactive remote tinker

+ bootstrapped remote machine is running
+ on local: `remote-doctor.sh sync`
+ loop until done:
  + on local: make changes in local files
  + on remote: `cd $src_dir; /usr/local/sbin/execute-saltstack.sh . state.highstate test=true`
+ done
+ on local: `remote-doctor.sh hard_reset --yes`


## gitops repository based Update System

### Execution

Can be triggered via webhook, systemd timer, or manual via
`systemctl start gitops-update`

Execute the following steps, any step that fails stops executing later steps:

+ `validate`: check the validity of the update, must not interrupt services!
    + default is `execute-saltstack.sh . state.highstate mock=true`
+ `before`: executed before "update", may stop services that may get restarted on finish
+ `update`: the acutal update command, default is `execute-saltstack.sh . state.highstate`
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

### Flags set and recognized

+ `gitops.update.failed`
+ `gitops.update.disabled`
+ `gitops.update.force`
+ `reboot.unattended.disabled`

### Tags set and recognized

+ `gitops_failed_rev`
+ `gitops_current_rev`

### Prometheus Metrics

+ `update_start_timestamp` counter "timestamp-epoch-seconds since last update to app"
+ `update_duration_sec` gauge "number of seconds for a update run"
+ `update_reboot_timestamp` counter "timestamp-epoch-seconds since update requested reboot"
+ `ssl_cert_valid_until` gauge "timestamp of certificate validity end date"

### Sentry Messages

+ info
  + `Gitops Execution` "Frontend Ready"

+ warning
  + `SSL Warning` "Certificate for $subject_cn is less than $min_days days valid\nValidity end date=$valid_until"

+ error
  + `Gitops Attention` "node needs reboot, human attention required"
  + `Gitops Error` "(validate_cmd|before_cmd|update_cmd|after_cmd|finish_cmd) failed with error $result"
  + `Service Error` "Service ($UNITNAME) failed" "$(unit_json_status)"
  + `SSL Error` "Certificate for $subject_cn is less than $min_days days valid\nValidity end date=$valid_until"
