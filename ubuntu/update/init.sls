
{% for i in ['20auto-upgrades', '50unattended-upgrades',] %}
/etc/apt/apt.conf.d/{{ i }}.ucf-dist:
  file:
    - absent
/etc/apt/apt.conf.d/{{ i }}:
  file.managed:
    - source: salt://ubuntu/update/{{ i }}
{% endfor %}

system_updates:
  pkg.installed:
    - pkgs:
      - apt
      - update-notifier-common
      - unattended-upgrades
