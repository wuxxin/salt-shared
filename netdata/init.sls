netdata:
  pkg.installed:
    - pkgs:
      - netdata
      - netcat-openbsd
      - fping
      - curl

{#

how to send a desktop notification, will get used to send netdata alarms to desktop user

+ DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$userid/bus" gosu $username bash -c 'notify-send "Notification Titel" "Notification Body" -u critical -i face-worried'

#}