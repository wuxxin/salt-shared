#!/bin/bash
set -eo pipefail
# set -x

usage () {
    echo "$0 --from-systemd-service"
    exit 1
}

if test -e "/usr/local/lib/app-library.sh"; then
    . "/usr/local/lib/app-library.sh"
else
    json_dict_get() { # $1=entry [$2..$x=subentry] , eg. gitops git source
        python3 -c "import sys, json, functools; print(functools.reduce(dict.__getitem__, sys.argv[1:], json.load(sys.stdin)))" $@
    }
    set_tag() { # $1=tagname $2=tagvalue
        echo "$2" > "{{ settings.tag_dir }}/$1"
    }
    get_tag() { # $1=tagname $2=default-if-not-found
        cat "{{ settings.tag_dir }}/$1" 2> /dev/null || echo "$2"
    }
    get_tag_fullpath() { # $1=tagname
        echo "{{ settings.tag_dir }}/$1"
    }
    mk_metric() { # $1=metric $2=value_type $3=helptext $4=value [$5=labels{,} [$6=timestamp]]
        echo "$@"
    }
    metric_save() { # $1=metric-output-name $2..$x=metric data
        printf "%s\n" "$@"
    }
    sentry_entry() { # $1=level $2=topic $3=message [$4=extra={} [$5=logger=app-status]]] ENV[UNITNAME]=culprit
        printf "%s\n" "$@"
    }
    unit_json_status() { # $UNITNAME
        pass
    }
fi

# save script start time ms
start_epoch_ms="$(date +%s)000"
start_epoch_seconds=$(date +%s)
duration_config=0; duration_hook=0; duration_backup=0; duration_cleanup=0; duration_forget=0
duration_prune=0; duration_check=0; duration_stats=0; duration_local_stats=0

# ###
# pre backup steps

# assure be called as {{ settings.user }} with param --from-systemd-service
if test "$(id -u -n)" != "{{ settings.user }}" -o "$1" != "--from-systemd-service"; then
    echo "Error: script should only be called as user {{ settings.user }}"
    usage
fi

# assure tag backup_repo_id is set
expected_id=$(get_tag backup_repo_id invalid)
if test "$expected_id" = "invalid"; then
    sentry_entry error "App Backup" \
        "backup error: repository id at $(get_tag_fullpath backup_repo_id) is missing or invalid.\n create/update repository id by using scripts/app-restic.sh)"
    exit 1
fi

# assure expected_id matches actual_id
duration_start=$(date +%s)
if ! { read actual_id < <(restic cat config --json| json_dict_get id); }; then
    sentry_entry "error" "App Backup" "backup error: could not get repository id from remote" \
        "$(unit_json_status)"
    exit 1
fi
duration_config=$(( $(date +%s) - duration_start ))
if test "$expected_id" != "$actual_id"; then
    sentry_entry "error" "App Backup" \
        "backup error: repository id missmatch\nexpected: $expected_id\nactual: $actual_id"
    exit 1
fi

# execute each entry of hooks.pre_backup
backup_hook_metrics=""
{% for hook in settings.hooks.pre_backup %}
duration_start=$(date +%s)
{{ hook.cmd }}
duration_hook=$(( $(date +%s) - duration_start ))
backup_hook_metrics="$backup_hook_metrics
$(mk_metric backup_pre_hook_{{ hook.name }}_duration_sec \
    gauge "Duration for {{ hook.description|d(hook.name) }}" $duration_hook)
"
{% endfor %}
metric_save backup_pre_hook "$backup_hook_metrics"

# ###
# all prebackup steps passed, begin backup work

# backup to thirdparty storage using restic
duration_start=$(date +%s)
{% set backup_excludes=
  '--exclude '+ settings.media_dir+ '/lost+found'+ ' '+
  '--exclude '+ settings.media_dir+ '/temp' %}

restic backup {{ backup_excludes }} {{ backup_list|join(" ") }} && err=$? || err=$?
duration_backup=$(( $(date +%s) - duration_start ))
if test "$err" -ne "0"; then
    sentry_entry "error" "App Backup" "backup error: backup failed with error $err" \
        "$(unit_json_status)"
    exit 1
fi


# ###
# post backup steps

# house keeping: call restic forget, prune and check, once every housekeeping interval
last_housekeeping=$(get_tag backup_housekeeping_timestamp 0)
oldest_expected_housekeeping=$(( start_epoch_seconds - housekeeping_interval_days * 60*60*24 ))

if test "$last_housekeeping" -le "$oldest_expected_housekeeping"; then
    set_tag backup_housekeeping_timestamp $start_epoch_seconds

    # XXX keep all snapshots from now to 1,5 years back, forget and prune older snapshots
    duration_start=$(date +%s)
    restic forget --{{ settings.forget }} && err=$? || err=$?
    duration_forget=$(( $(date +%s) - duration_start ))
    if test "$err" -ne "0"; then
        sentry_entry "error" "App Backup" "backup error: forget returned error" \
            "$(unit_json_status)"
    fi

    duration_start=$(date +%s)
    restic prune && err=$? || err=$?
    duration_prune=$(( $(date +%s) - duration_start ))
    if test "$err" -ne "0"; then
        sentry_entry "error" "App Backup" "backup error: prune returned error" \
            "$(unit_json_status)"
    fi

    duration_start=$(date +%s)
    restic check && err=$? || err=$?
    duration_check=$(( $(date +%s) - duration_start ))
    if test "$err" -ne "0"; then
        sentry_entry "error" "App Backup" "backup error: repository check returned error" \
            "$(unit_json_status)"
    fi
fi

# clean cache after main backup work is done
duration_start=$(date +%s)
restic cache --cleanup && err=$? || err=$?
duration_cleanup=$(( $(date +%s) - duration_start ))
if test "$err" -ne "0"; then
    sentry_entry "warning" "App Backup" "backup warning: cache --cleanup returned error" \
        "$(unit_json_status)"
fi

{% if settings.count_backup_data_size %}
# calculate used space on backup storage
backup_target_data_size_kb=0
duration_start=$(date +%s)
if ! { read backup_used_size < <(restic stats --mode raw-data --json | \
    json_dict_get total_size); }; then
    sentry_entry "warning" "App Backup" "backup warning: stats returned error" \
        "$(unit_json_status)"
else
    backup_target_data_size_kb=$(( backup_used_size/1024 ))
fi
duration_stats=$(( $(date +%s) - duration_start ))
{% endif %}

{% if settings.count_local_data_size %}
# sum the local filesizes of the backuped data
duration_start=$(date +%s)
backup_local_data_size_kb=$(du --apparent-size --summarize --total -BK \
    {{ backup_list|join(" ") }} | grep total | sed -r "s/([0-9]+).*/\1/")
duration_local_stats=$(( $(date +%s) - duration_start ))
{% endif %}

# execute each entry of hooks.post_backup
backup_hook_metrics=""
{% for hook in settings.hooks.post_backup %}
duration_start=$(date +%s)
{{ hook.cmd }}
duration_hook=$(( $(date +%s) - duration_start ))
backup_hook_metrics="$backup_hook_metrics
$(mk_metric backup_post_hook_{{ hook.name }}_duration_sec \
    gauge "Duration for {{ hook.description|d(hook.name) }}" $duration_hook)
"
{% endfor %}
metric_save backup_post_hook "$backup_hook_metrics"

# calculate runtime
end_epoch_seconds=$(date +%s)
duration=$(( end_epoch_seconds - start_epoch_seconds ))

# create all other metrics
metric_save backup \
    "$(mk_metric backup_start_timestamp counter "The start of the last backup run as timestamp-epoch-seconds" ${start_epoch_seconds})" \
    "$(mk_metric backup_duration_sec gauge "The duration in number of seconds of the last backup run" $duration)" \
    "$(mk_metric backup_target_data_size_kb gauge "The number of kilo-bytes used in the backup space" $backup_target_data_size_kb)" \
    "$(mk_metric backup_local_data_size_kb gauge "The sum of the local filesizes of the backuped files in kilo-bytes" $backup_local_data_size_kb)"

metric_save backup_ext \
    "$(mk_metric backup_config_duration_sec gauge "The duration in number of seconds of the backup config run" $duration_config)" \
    "$(mk_metric backup_backup_duration_sec gauge "The duration in number of seconds of the actual backup run" $duration_backup)" \
    "$(mk_metric backup_forget_duration_sec gauge "The duration in number of seconds of the backup forget run" $duration_forget)" \
    "$(mk_metric backup_prune_duration_sec gauge "The duration in number of seconds of the backup prune run" $duration_prune)" \
    "$(mk_metric backup_check_duration_sec gauge "The duration in number of seconds of the backup check run" $duration_check)" \
    "$(mk_metric backup_cleanup_duration_sec gauge "The duration in number of seconds of the backup cleanup run" $duration_cleanup)" \
    "$(mk_metric backup_stats_duration_sec gauge "The duration in number of seconds of the backup stats run" $duration_stats)" \
    "$(mk_metric backup_stats_local_duration_sec gauge "The duration in number of seconds of the local stats run" $duration_stats_local)"
