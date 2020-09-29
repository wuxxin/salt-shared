#!/bin/bash
set -eo pipefail
# set -x

usage () {
    echo "$0 --from-systemd-service"
    exit 1
}

. "/usr/local/lib/app-library.sh"

# save script start time ms
start_epoch_ms="$(date +%s)000"
start_epoch_seconds=$(date +%s)
duration_config=0; duration_pg_dump=0; duration_backup=0; duration_cleanup=0
duration_forget=0; duration_prune=0; duration_check=0; duration_stats=0

# ###
# pre backup hooks

# assure be called as {{ settings.user }} with param --from-systemd-service
if test "$(id -u -n)" != "{{ settings.user }}" -o "$1" != "--from-systemd-service"; then
    echo "Error: script should only be called as user {{ settings.user }}"
    usage
fi

# assure tag app_backup_id is set
expected_id=$(get_tag app_backup_id invalid)
if test "$expected_id" = "invalid"; then
    sentry_entry error "App Backup" \
        "backup error: repository id at $(get_tag_fullpath app_backup_id) is missing or invalid.\n create/update repository id by using scripts/app-restic.sh)"
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

{% for hook in settings.prebackup %}
# {{ hook.name }}
{{ hook.cmd }}
{% endfor %}

# ###
# all prebackup hooks passed, begin backup work

# backup to thirdparty storage
duration_start=$(date +%s)
restic backup {{ backup_excludes }} {{ backup_list|join(" ") }} && err=$? || err=$?
duration_backup=$(( $(date +%s) - duration_start ))
if test "$err" -ne "0"; then
    sentry_entry "error" "App Backup" "backup error: backup failed with error $err" \
        "$(unit_json_status)"
    exit 1
fi


# ###
# post backup

# TODO house cleaning: call restic forget, prune and check, once a week
if test "true" = "true"; then
    # XXX keep all snapshots from now to 1,5 years back, forget and prune older snapshots
    duration_start=$(date +%s)
    restic forget --keep-within 1y6m && err=$? || err=$?
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

# calculate used space on backup storage
backup_used_size_kb=0
duration_start=$(date +%s)
if ! { read backup_used_size < <(restic stats --mode raw-data --json | \
    json_dict_get total_size); }; then
    sentry_entry "warning" "App Backup" "backup warning: stats returned error" \
        "$(unit_json_status)"
else
    backup_used_size_kb=$(( backup_used_size/1024 ))
fi
duration_stats=$(( $(date +%s) - duration_start ))

# sum the local filesizes of the backuped data
backup_data_size_kb=$(du --apparent-size --summarize --total -BK \
    {{ backup_list|join(" ") }} | grep total | sed -r "s/([0-9]+).*/\1/")

# calculate runtime
end_epoch_seconds=$(date +%s)
duration=$(( end_epoch_seconds - start_epoch_seconds ))

# create metrics
metric_save backup \
    "$(mk_metric backup_start_timestamp counter "The start of the last backup run as timestamp-epoch-seconds" ${start_epoch_seconds})" \
    "$(mk_metric backup_duration_sec gauge "The duration in number of seconds of the last backup run" $duration)" \
    "$(mk_metric backup_used_size_kb gauge "The number of kilo-bytes used in the backup space" $backup_used_size_kb)" \
    "$(mk_metric backup_data_size_kb gauge "The sum of the local filesizes of the backuped files in kilo-bytes" $backup_data_size_kb)"

metric_save backup_ext \
    "$(mk_metric backup_config_duration_sec gauge "The duration in number of seconds of the backup config run" $duration_config)" \
    "$(mk_metric backup_pg_dump_duration_sec gauge "The duration in number of seconds of the database dump run" $duration_pg_dump)" \
    "$(mk_metric backup_backup_duration_sec gauge "The duration in number of seconds of the actual backup run" $duration_backup)" \
    "$(mk_metric backup_forget_duration_sec gauge "The duration in number of seconds of the backup forget run" $duration_forget)" \
    "$(mk_metric backup_prune_duration_sec gauge "The duration in number of seconds of the backup prune run" $duration_prune)" \
    "$(mk_metric backup_check_duration_sec gauge "The duration in number of seconds of the backup check run" $duration_check)" \
    "$(mk_metric backup_cleanup_duration_sec gauge "The duration in number of seconds of the backup cleanup run" $duration_cleanup)" \
    "$(mk_metric backup_stats_duration_sec gauge "The duration in number of seconds of the backup stats run" $duration_stats)"
