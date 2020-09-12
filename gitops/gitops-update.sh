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
    custom_args=""
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
    latest_commit_msg=$(gosu "$src_user" git -C "$src_dir" log -1 --pretty=format:%B)

    if test "$latest_origin_rev" != "$current_origin_rev" -o \
        "$latest_origin_rev" != "$(get_tag gitops_current_rev "invalid")" -o \
        -e "{{ settings.var_dir }}/flags/gitops.update.force"; then

        msg="Updating app from $current_origin_rev to $latest_origin_rev"
        if test "$current_origin_rev" = "$latest_origin_rev"; then
            msg="Reapplying Update $latest_origin_rev"
        fi
        if test -e "{{ settings.var_dir }}/flags/gitops.update.force"; then
            rm "{{ settings.var_dir }}/flags/gitops.update.force"
        fi
        simple_metric update_start_timestamp counter \
            "timestamp-epoch-seconds since last update to app" "$start_epoch_ms"
        cd $src_dir

        echo "calling validate_cmd"
        {{ settings.update.validate_cmd }} && result=$? || result=$?
        if test $result -ne 0; then
            gitops_error "Gitops Error" "validate_cmd failed with error $result" \
                error "$(systemd_json_status "$UNITNAME")"
        else
            echo "validation successful, display gitops maintenance information"
            gitops_maintenance "Gitops Update" "$msg"
            need_service_restart="true"

            echo "calling before_cmd"
            {{ settings.update.before_cmd }} && result=$? || result=$?
            if test $result -ne 0; then
                gitops_error "Gitops Error" "before_cmd failed with error $result" \
                    error "$(systemd_json_status "$UNITNAME")"
            else
                echo "calling update_cmd"
                {{ settings.update.update_cmd }} && result=$? || result=$?
                if test $result -ne 0; then
                    set_tag gitops_failed_rev "$latest_origin_rev"
                    gitops_error "Gitops Error" "update_cmd failed with error $result" \
                        error "$(systemd_json_status "$UNITNAME")"
                else
                    set_tag gitops_current_rev "$latest_origin_rev"
                    echo "calling after_cmd"
                    {{ settings.update.after_cmd }} && result=$? || result=$?
                    if test $result -ne 0; then
                        gitops_error "Gitops Error" "after_cmd failed with error $result" \
                            error "$(systemd_json_status "$UNITNAME")"
                    fi
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
        echo "calling finish_cmd_command"
        {{ settings.update.finish_cmd }} && result=$? || result=$?
        if test $result -ne 0; then
            gitops_error "Gitops Error" "finish_cmd failed with error $result" \
                error "$(systemd_json_status "$UNITNAME")"
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
