#!/bin/sh

logread -e "hostapd:.*AP-STA-" -f | tr '\n' '\0' | \
    xargs -n 1 -0 /usr/bin/hostapd_hook_mqtt.sh --log-line
