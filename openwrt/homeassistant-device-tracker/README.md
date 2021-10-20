# openwrt wifi device presence to MQTT publish for homeassistant

+ based on https://forum.fhem.de/index.php?topic=113524.0
+ can use logread or hostapd_cli for information gathering
    + XXX currently only logread is working,
      because hostapd_cli hook misses the connect after a disconnect/connect renew

## install

+ `opkg install coreutils-nohup hostapd-utils mosquitto-client-ssl`
+ copy to /etc:
  + `hostapd_hook_mqtt_credentials.conf`
  + `hostapd_hook_mqtt_cafile.crt`
+ copy to /usr/bin:
  + `hostapd_hook_mqtt.sh`
  + `logread_hook_mqtt.sh`
+ append /etc/rc.local contents to current /etc/rc.local
+ add custom files to backup and make router backup
```
/etc/hostapd_hook_mqtt_credentials.conf
/etc/hostapd_hook_mqtt_cafile.crt
/usr/bin/hostapd_hook_mqtt.sh
/usr/bin/logread_hook_mqtt.sh
```
+ reboot router

## usage

+ Homeassistant will autodiscover the wifi clients as device_tracker
  + known static Wifi Clients will be available under  `device_tracker.<dhcp_name>`
  + other Wifi Clients as `device_tracker.guest-<mac_address>`
