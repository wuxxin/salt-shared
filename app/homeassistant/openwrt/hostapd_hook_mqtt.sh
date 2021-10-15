#!/bin/sh
# called from hostapd with $0 <interface> <event> <device_mac>
# advertise to mqtt topic "home-assistant/device_tracker/openwrt"
# write playload(AP-STA-CONNECTED, AP-STA-DISCONNECTED) to mqtt topic "openwrt/$device_id/state"
interface=$1
event=$2
device_mac=$(echo $3 | tr a-z A-Z)
config_file="/etc/hostapd_hook_mqtt.conf"

# only react to states connected and disconnected
if [ "$event" != "AP-STA-CONNECTED" ] && [ "$event" != "AP-STA-DISCONNECTED" ] ; then exit 0; fi
# exit if missing config file
if [ ! -e "$config_file" ] ; then echo "error, hook: config file $config_file not found"; exit 1; fi

# get device name, use "guest" if no fixed name is found
var1=$(uci show dhcp | grep -oE "host\[\d+\].mac='"$device_mac"'"|grep -oE "\[(\d+)\]")
device_name=$(uci get dhcp.@host${var1}.name)
if [ -z "$device_name" ] ; then device_name="guest" ; fi
device_id="$device_name:$device_mac"

# read amqtt config
MQTT_host=""
MQTT_port=""
MQTT_user=""
MQTT_pwd=""
. /etc/hostapd_hook_mqtt.conf
MQTT_client=openwrt_$interface
MQTT_message=$event
MQTT_topic="openwrt/$device_id/state"
HASS_discovery_dir="/var/lib/home-assistant"
HASS_discovery_base="home-assistant/device_tracker/openwrt"

if [ ! -e "$HASS_discovery_dir/$device_id" ] ; then
  # advertise as device_tracker in home-assistant, once per reboot
  touch "$HASS_discovery_dir/$device_id"
  HASS_discovery_payload=$(cat << EOF
{
  "state_topic": "$MQTT_topic",
  "source_type": "router",
  "payload_home": "AP-STA-CONNECTED",
  "payload_not_home": "AP-STA-DISCONNECTED"
}
EOF
)
  mosquitto_pub -h "$MQTT_host" -p "$MQTT_port" \
    -i "$MQTT_client" -u "$MQTT_user" -P "$MQTT_pwd" \
    -t "$HASS_discovery_base/$device_id/config" -m "$HASS_discovery_payload"
fi

# send current connection status of device to MQTT
mosquitto_pub -h "$MQTT_host" -p "$MQTT_port" \
  -i "$MQTT_client" -u "$MQTT_user" -P "$MQTT_pwd" \
  -t $MQTT_topic -m $MQTT_message
