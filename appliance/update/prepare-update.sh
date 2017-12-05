prepare_update () {
    local oncalendar timertarget
    timertarget=/etc/systemd/system/appliance-update.timer
    if test "$(printf "%s" "$APPLIANCE_UPDATE_AUTOMATIC" | tr A-Z a-z)" = "false"; then
        if test -L $timertarget -a "$(readlink -f $timertarget)" = "/dev/null"; then
            echo "Information: $timertarget already a symlink pointing to /dev/null"
        else
            echo "Warning: removing current $timertarget and symlink to /dev/null"
            if systemctl is-enabled appliance-update.timer; then
                systemctl disable appliance-update.timer || true
            fi
            if systemctl is-active appliance-update.timer; then
                systemctl stop appliance-update.timer || true
            fi
            ln -s -f -T /dev/null $timertarget
            systemctl daemon-reload
        fi
    else
        if test "${APPLIANCE_UPDATE_ONCALENDAR}" != ""; then
            echo "Information: Setting custom oncalendar schedule: ${APPLIANCE_UPDATE_ONCALENDAR}"
            oncalendar="OnCalendar=${APPLIANCE_UPDATE_ONCALENDAR}"
        else
            # xxx default should be the same as in appliance-update.timer source
            oncalendar="OnCalendar=*-*-* 06:30:00"
        fi
        cat ${timertarget}.template | sed "s/^OnCalendar=.*/$oncalendar/" > ${timertarget}.new
        if ! diff -q $timertarget ${timertarget}.new; then
            echo "Warning: appliance-update.timer changed, reloading timer"
            diff -u ${timertarget} ${timertarget}.new
            cp --remove-destination ${timertarget}.new ${timertarget}
            systemctl daemon-reload
            systemctl restart appliance-update.timer
        fi
    fi
}
