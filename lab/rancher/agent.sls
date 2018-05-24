include:
  - lab.rancher.common
  - lab.rancher.server
  
{% from "lab/rancher/defaults.jinja" import settings with context %}

rancher-agent-setup:
  file.managed:
    - source: salt://lab/rancher/rancher-agent-setup.sh
    - name: /etc/rancher/rancher-agent-setup.sh

  cmd.run:
    - name: /etc/rancher/rancher-agent-setup.sh
    - unless: test -e /etc/rancher/rancher-agent.env
    - require:
      - sls: lab.rancher.server
  
rancher-agent:
  file.managed:
    - source: salt://lab/rancher/rancher-agent.service
    - name: /etc/systemd/system/rancher-agent.service
    - template: jinja
    - context:
      settings: {{ settings }}
    - onchanges_in:
      - cmd: systemd_reload
    - require:
      - cmd: rancher-agent-setup
      - sls: lab.rancher.common
  
  service.running:
    - enable: true
    - watch:
      - file: rancher-agent
    - require:
      - file: rancher-agent
      

