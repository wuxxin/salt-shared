include:
  - appliance.base
  - systemd.reload


{% for n in [
  'env-prepare.service', 'appliance-prepare.service', 
  'service-failed@.service',
  'mail-to-sentry.service', 'mail-to-sentry.path',
  ] %}
install_{{ n }}:
  file.managed:
    - name: /etc/systemd/system/{{ n }}
    - source: salt://appliance/systemd/{{ n }}
    - watch_in:
      - cmd: systemd_reload
    - require:
      - sls: appliance.base
{% endfor %}


install_appliance.service:
  file.managed:
    - name: /etc/systemd/system/appliance.service
    - source: salt://appliance/systemd/appliance.service
    - watch_in:
      - cmd: systemd_reload
  cmd.wait:
    - name: systemctl enable appliance.service
    - order: last
    - watch:
      - file: install_appliance.service