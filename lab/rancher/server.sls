include:
  - lab.rancher.common
  
{% from "lab/rancher/defaults.jinja" import settings with context %}

rancher-server-volume:
  file.directory:
    - name: {{ settings.server.volume }}
  docker_volume.present:
    - name: rancher-server-volume
    - driver: local
    - driver_opts:
       type: "none"
       device: "{{ settings.server.volume }}"
       o: "bind"
    - require:
      - file: rancher-server-volume
      - sls: lab.rancher.common
    
rancher-server-image:
  docker_image.present:
    - name: rancher/rancher:{{ settings.server.tag }}
    - require:
      - sls: lab.rancher.common

rancher-server:
  file.managed:
    - source: salt://lab/rancher/rancher-server.service
    - name: /etc/systemd/system/rancher-server.service
    - template: jinja
    - context:
      settings: {{ settings }}
    - onchanges_in:
      - cmd: systemd_reload
    - require:
      - sls: lab.rancher.common
  service.running:
    - enable: true
    - watch:
      - file: rancher-server
    - require:
      - file: rancher-server
      
/etc/rancher/rancher-server-setup.sh:
  file.managed:
    - source: salt://lab/rancher/rancher-server-setup.sh
    - mode: "0755"
    - template: jinja
    - context:
      settings: {{ settings }}
  cmd.run:
    - unless: test -e /etc/rancher/rancher-server.env
    - require:
      - file: /etc/rancher/rancher-server-setup.sh
      - service: rancher-server
