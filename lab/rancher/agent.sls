include:
  - lab.rancher.common
  - lab.rancher.server
  - systemd.reload
  
{% from "lab/rancher/defaults.jinja" import settings with context %}

/etc/rancher/rancher-agent-setup.sh:
  file.managed:
    - source: salt://lab/rancher/rancher-agent-setup.sh
    - mode: "0755"
    - template: jinja
    - context:
      settings: {{ settings }}
  cmd.run:
    - unless: test -e /etc/rancher/rancher-agent.env
    - require:
      - file: /etc/rancher/rancher-agent-setup.sh
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
      - cmd: /etc/rancher/rancher-agent-setup.sh
      - sls: lab.rancher.common
  
  service.running:
    - enable: true
    - watch:
      - file: rancher-agent
    - require:
      - file: rancher-agent
      

