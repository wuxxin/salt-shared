include:
  - python

netdata:
  pkg.installed:
    - pkgs:
      - fping
      - netdata
      - netdata-plugins-python
    - require:
      - sls: python

{#
how to send a desktop notification, will get used to send netdata alarms to desktop user

+ DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$userid/bus" gosu $username bash 'notify-send "Notification Titel" "Notification Body" -u critical -i face-worried'

#}
