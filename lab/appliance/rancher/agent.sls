include:
  - .common
  - .server
  
{% from "lab/appliance/rancher/defaults.jinja" import settings with context %}

rancher-agent-setup:
  file.managed:
    - source: salt://lab/appliance/rancher/rancher-agent-setup.sh
    - name: /usr/local/share/appliance/rancher-agent-setup.sh

  cmd.run:
    - name: /usr/local/share/appliance/rancher-agent-setup.sh
    - unless: test -e /app/etc/rancher-agent.env
    - require:
      - sls: .server
  
rancher-agent.service:
  file.managed:
    - source: salt://lab/appliance/rancher/rancher-agent.service
    - name: /etc/systemd/system/rancher-agent.service
    - template: jinja
    - context:
      settings: {{ settings }}
    - onchanges_in:
      - cmd: systemd_reload
    - require:
      - cmd: rancher-agent-setup
      - sls: .common
  
  service.running:
    - enable: true
    - watch:
      - file: rancher-agent.service
    - require:
      - file: rancher-agent.service
      

