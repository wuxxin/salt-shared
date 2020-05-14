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

    # update origin repository source, remember old and new HEAD
    current_origin_rev="$(gosu "$src_user" git -C "$src_dir" rev-parse HEAD)"
    /usr/local/sbin/from-git.sh pull --url "$src_url" --branch "$src_branch" --user "$src_user" --git-dir "$src_dir"
    latest_origin_rev="$(gosu "$src_user" git -C "$src_dir" rev-parse HEAD)"

    if test "$latest_origin_rev" != "$current_origin_rev" -o \
        "$latest_origin_rev" != "$(get_tag gitops_current_rev "invalid")" -o \
        -e "{{ settings.var_dir }}/flags/force.app.update"; then

        simple_metric update_start_timestamp counter "timestamp-epoch-seconds since last update to app" "$start_epoch_ms"
        if test "$(get_gitrev "$src_dir")" = "$latest_origin_rev"; then
            msg="Reapplying Update $latest_origin_rev"
        else
            msg="Updating app from $(get_gitrev "$src_dir") to $latest_origin_rev"
        fi

        # execute stop app
        gitops_maintenance "Gitops Update" "$msg"
        echo "Information: executing pre_update_command"
        {{ settings.pre_update_command }} && err=$? || err=$?
        if test $err -ne 0; then
            extra=$(systemctl status -l -q --no-pager -n 10 "$UNITNAME" | text2json_status)
            gitops_error "Gitops Error" \
                "pre_update_command failed with error $err" error "$extra"
            exit 1
        fi
        need_service_restart="true"

        # call gitops update procedure, defaults to execute-saltstack.sh
        cd $src_dir
        {{ settings.update_command }} && err=$? || err=$?
        if test $err -ne 0; then
            extra=$(systemctl status -l -q --no-pager -n 10 "$UNITNAME" | text2json_status)
            gitops_error "Gitops Error" \
                "update command failed with error $err" error "$extra"
            set_tag_from_file gitops_failed_rev "{{ settings.staging_dir }}/GIT_REV"
        fi
    fi

    if test -e /run/reboot-required; then
        if flag_is_set no.automatic.reboot; then
            echo "Warning: reboot of system required, but automatic reboot not allowed; contacting admin"
            sentry_entry "Gitops Attention" "node needs reboot, human attantion required" error
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

    if $need_service_restart; then
        echo "Information: executing post_update_command"
        {{ settings.post_update_command }} && err=$? || err=$?
        if test $err -ne 0; then
            extra=$(systemctl status -l -q --no-pager -n 10 "$UNITNAME" | text2json_status)
            gitops_error "Gitops Error" \
                "post_update_command failed with error $err" error "$extra"
            exit 1
        fi
    fi
    echo "Information: all done, enable access to frontend service"
    gitops_maintenance --clear

    simple_metric update_duration_sec gauge \
        "number of seconds for a update run" $(($(date +%s)000 - start_epoch_ms))
    exit 0
}

main "$@"