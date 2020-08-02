#!/bin/bash
set -eo pipefail
# set -x


usage () {
    echo "$0 --from-systemd-service"
    echo "hint: use 'systemctl start gitops-update' instead"
    exit 1
}

if test "$(id -u)" != "0" -o "$1" != "--from-systemd-service"; then
    echo "Error: script should only be called from systemd gitops-update.service"
    usage
fi
if test "$src_user" = "" -o "$src_url" = "" -o "$src_branch" = "" -o "$src_dir" = ""; then
    echo "Error: Missing mandatory environment: src_user, src_url, src_branch, src_dir"
    usage
fi

. /usr/local/lib/gitops-library.sh

main () {
    start_epoch_ms="$(date +%s)000"
    need_service_restart="false"
    result=0

    if flag_is_set gitops.update.failed; then
        if flag_is_set gitops.update.force; then
            echo "Warning: gitops.update.failed flag is set, but gitops.update.force flag also, forcing update, removing failed flag"
            del_flag gitops.update.failed
        else
            echo "Error: gitops.update.failed flag is set, abort. Either delete flag, or set gitops.update.force to ignore"
            exit 1
        fi
    fi
    if flag_is_set gitops.update.disable; then
        echo "Warning: gitops.update.disable flag is set, exit update run without update"
        simple_metric update_duration_sec gauge \
            "number of seconds for a update run" $(($(date +%s)000 - start_epoch_ms))
        exit 0
    fi

    echo "update origin repository source"
    current_origin_rev="$(gosu "$src_user" git -C "$src_dir" rev-parse HEAD)"
    /usr/local/sbin/from-git.sh pull --url "$src_url" --branch "$src_branch" --user "$src_user" --git-dir "$src_dir"
    latest_origin_rev="$(gosu "$src_user" git -C "$src_dir" rev-parse HEAD)"

    if test "$latest_origin_rev" != "$current_origin_rev" -o \
        "$latest_origin_rev" != "$(get_tag gitops_current_rev "invalid")" -o \
        -e "{{ settings.var_dir }}/flags/gitops.update.force"; then

        need_service_restart="true"
        msg="Updating app from $current_origin_rev to $latest_origin_rev"
        if test "$current_origin_rev" = "$latest_origin_rev"; then
            msg="Reapplying Update $latest_origin_rev"
        fi
        if test -e "{{ settings.var_dir }}/flags/gitops.update.force"; then
            rm "{{ settings.var_dir }}/flags/gitops.update.force"
        fi
        gitops_maintenance "Gitops Update" "$msg"
        simple_metric update_start_timestamp counter \
            "timestamp-epoch-seconds since last update to app" "$start_epoch_ms"
        cd $src_dir

        echo "calling pre_update_command"
        {{ settings.pre_update_command }} && result=$? || result=$?
        if test $result -ne 0; then
            extra=$(systemctl status -l -q --no-pager -n 10 "$UNITNAME" | text2json_status)
            gitops_error "Gitops Error" \
                "pre_update_command failed with error $result" error "$extra"
        else
            echo "calling update_command, defaults to execute-saltstack.sh"
            {{ settings.update_command }} && result=$? || result=$?
            if test $result -ne 0; then
                set_tag_from_file gitops_failed_rev "$latest_origin_rev"
                extra=$(systemctl status -l -q --no-pager -n 10 "$UNITNAME" | text2json_status)
                gitops_error "Gitops Error" \
                    "update command failed with error $result" error "$extra"
            else
                set_tag_from_file gitops_current_rev "$latest_origin_rev"
                echo "calling post_update_command"
                {{ settings.post_update_command }} && result=$? || result=$?
                if test $result -ne 0; then
                    extra=$(systemctl status -l -q --no-pager -n 10 "$UNITNAME" | text2json_status)
                    gitops_error "Gitops Error" \
                        "post_update_command failed with error $result" error "$extra"
                fi
            fi
        fi
    fi

    if test -e /run/reboot-required; then
        if flag_is_set reboot.automatic.disable; then
            echo "Warning: reboot of system required, but automatic reboot not allowed; contacting admin"
            sentry_entry "Gitops Attention" "node needs reboot, human attention required" error
        else
            echo "Warning: reboot of system required, initiating automatic reboot"
            simple_metric update_duration_sec gauge \
                "number of seconds for a update run" $(($(date +%s)000 - start_epoch_ms))
            simple_metric update_reboot_timestamp counter \
                "timestamp-epoch-seconds since update requested reboot" "$start_epoch_ms"
            systemctl --no-block reboot
            exit 0
        fi
    fi

    if test "$need_service_restart" = "true" -a "$result" = "0"; then
        echo "calling finish_update_command"
        {{ settings.finish_update_command }} && result=$? || result=$?
        if test $result -ne 0; then
            extra=$(systemctl status -l -q --no-pager -n 10 "$UNITNAME" | text2json_status)
            gitops_error "Gitops Error" \
                "finish_update_command failed with error $result" error "$extra"
        fi
    fi

    if test "$need_service_restart" = "true" -a "$result" = "0"; then
        echo "Information: all done, enable access to frontend service"
        gitops_maintenance --clear
    fi

    simple_metric update_duration_sec gauge \
        "number of seconds for a update run" $(($(date +%s)000 - start_epoch_ms))
    exit $result
}

main "$@"
