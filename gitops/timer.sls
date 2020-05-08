{% from "gitops/defaults.jinja" import settings with context %}

{% if settings.timer.enabled|d(false) %}

/etc/systemd/system/gitops-update.timer:
  file.managed:
    - source: salt://gitops/gitops-update.timer
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - onchanges_in:
      - cmd: systemd_reload
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
    - onchanges_in:
      - cmd: systemd_reload

{%- endif %}
