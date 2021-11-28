#!/bin/sh

# Usage from logread:
#   `logread -e "hostapd:.*AP-STA-" -f | tr '\n' '\0' | \
#      xargs -n 1 -0 /usr/bin/hostapd_hook_mqtt.sh --log-line`
#
# Example logline:
#   "Tue Oct 19 23:16:37 2021 daemon.notice hostapd: wlan0-1: AP-STA-DISCONNECTED 12:34:56:78:90:ab"
#
# Usage from hostapd_cli: $0 <interface> <event> <device_mac>
#   `hostapd_cli -i wlan0-1 -B -r -a /usr/bin/hostapd_hook_mqtt.sh`
#
# Workflow:
#   on first connect/disconnect of a device since last openwrt reboot:
#     advertise the device to mqtt topic "homeassistant/device_tracker/openwrt/<device_id>"
#     device_id is the mac-id of the tracked device uppercase and ":" translated to "_"
#     device (friendly) name will be taken from the dhcp name or set to "guest-<macid>"
#
#   on connect or disconnect of a device:
#     write payload ["AP-STA-CONNECTED", "AP-STA-DISCONNECTED"] to mqtt "openwrt/$device_id/state"
#
# both advertisement and device connection status is published with the retain flag set
#

if [ "$1" = "--log-line" ] ; then
    shift
    logline=$(printf "%s" "$@" | sed -r "s/^.+hostapd: ([^:]+): ([^ ]+) (.+)$/\1 \2 \3/g")
    interface=${logline%% *}
    event=${logline#* }; event=${event%% *}
    device_mac=$(echo "${logline##* }" | tr a-z A-Z)
else
    interface=$1
    event=$2
    device_mac=$(echo $3 | tr a-z A-Z)
fi
device_id="$(echo "$device_mac" | tr ":" "_")"
config_file="/etc/hostapd_hook_mqtt_credentials.conf"

# only act on states connected and disconnected
if [ "$event" != "AP-STA-CONNECTED" ] && [ "$event" != "AP-STA-DISCONNECTED" ] ; then
    exit 0
fi
# exit if missing config file
if [ ! -e "$config_file" ] ; then
    logger -s -p error -t mqtt_hook "error, hook config file $config_file not found"
    exit 1
fi

MQTT_host=localhost; MQTT_port=1883; MQTT_user=""; MQTT_pwd=""; MQTT_cafile=""
. $config_file
MQTT_client=openwrt_$interface
MQTT_message=$event
MQTT_topic="openwrt/$device_id/state"
MQTT_baseurl="mqtts://${MQTT_user}:${MQTT_pwd}@${MQTT_host}:${MQTT_port}"
MQTT_additional=""
if [ ! -z "$MQTT_cafile" ] ; then MQTT_additional="--cafile $MQTT_cafile"; fi
HASS_discovery_dir="/var/lib/homeassistant"
HASS_discovery_base="homeassistant/device_tracker"

if [ -e "$HASS_discovery_dir/$device_id" ] ; then
    # read device_name from HASS_discovery_payload
    device_name=$(cat "$HASS_discovery_dir/$device_id" | \
        grep '"name":' | sed -r 's/ +"name": "([^"]*)",/\1/g')
else
    # get device_name, use "guest-<device_mac>" if no fixed name can be found
    device_name="$(echo "guest-$device_mac" | tr ":" "_")"
    var1=$(uci show dhcp | grep -oiE "host\[\d+\].mac='"$device_mac"'"|grep -oE "\[(\d+)\]")
    if [ ! -z "$var1" ] ; then
        device_name=$(uci get dhcp.@host${var1}.name)
    fi
    HASS_discovery_payload=$(cat << EOF
{
  "state_topic": "$MQTT_topic",
  "source_type": "router",
  "name": "$device_name",
  "payload_home": "AP-STA-CONNECTED",
  "payload_not_home": "AP-STA-DISCONNECTED"
}
EOF
)
    # write discovery playload to ramdisk, reboot will clear this list
    if [ ! -d $HASS_discovery_dir ] ; then mkdir -p $HASS_discovery_dir; fi
    echo "$HASS_discovery_payload" > "$HASS_discovery_dir/$device_id"

    # advertise as device_tracker in homeassistant
    # retain message for quicker pickup on restart of components
    mosquitto_pub -i "$MQTT_client" \
        -L "${MQTT_baseurl}/${HASS_discovery_base}/${device_id}/config" \
        -m "$HASS_discovery_payload" -q 1 -r ${MQTT_additional}
fi

# send current connection status of device to MQTT,
#   retain message for quicker pickup on restart of components
# logger -s -p info -t mqtt_hook \
#    "send: interface: $interface , event: $event , device_id: $device_id , device_name: $device_name"
mosquitto_pub -i "$MQTT_client" \
  -L "${MQTT_baseurl}/$MQTT_topic" -m "$MQTT_message" -q 1 -r ${MQTT_additional}
