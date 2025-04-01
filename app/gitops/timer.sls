{% from "app/gitops/defaults.jinja" import settings with context %}
include:
  - app.gitops.service

{% if settings.timer.enabled|d(false) %}

/etc/systemd/system/gitops-update.timer:
  file.managed:
    - source: salt://app/gitops/gitops-update.timer
    - template: jinja
    - defaults:
        settings: {{ settings }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/gitops-update.timer
  service.running:
    - name: gitops-update.timer
    - enable: true
    - require:
      - file: /usr/local/sbin/gitops-update.sh
      - file: /etc/systemd/system/gitops-update.service
      - file: /etc/systemd/system/gitops-update.timer
    - watch:
      - file: /etc/systemd/system/gitops-update.service
      - file: /etc/systemd/system/gitops-update.timer

{% else %}

disable-gitops-update.timer:
  cmd.run:
    - name: systemctl disable gitops-update.timer || true
    - onlyif: systemctl is-enabled gitops-update.timer

stop-gitops-update.timer:
  cmd.run:
    - name: systemctl stop gitops-update.timer || true
    - onlyif: systemctl is-active gitops-update.timer

/etc/systemd/system/gitops-update.timer:
  file.symlink:
    - target: /dev/null
    - force: true
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/gitops-update.timer

{%- endif %}
