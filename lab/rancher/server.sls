include:
  - .common
  
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
      - sls: .common
    
rancher-server-image:
  docker_image.present:
    - name: rancher/rancher:{{ settings.server_tag }}
    - require:
      - sls: .common

rancher-server.service:
  file.managed:
    - source: salt://lab/rancher/rancher-server.service
    - name: /etc/systemd/system/rancher-server.service
    - template: jinja
    - context:
      settings: {{ settings }}
    - onchanges_in:
      - cmd: systemd_reload
    - require:
      - sls: .common

  service.running:
    - enable: true
    - watch:
      - file: rancher-server.service
    - require:
      - file: rancher-server.service
      
rancher-server-setup:
  file.managed:
    - source: salt://lab/rancher/rancher-server-setup.sh
    - name: /usr/local/share/appliance/rancher-server-setup.sh
    - mode: "0755"
  cmd.run:
    - name: /usr/local/share/appliance/rancher-server-setup.sh
    - unless: test -e /app/etc/rancher-server.env
    - require:
      - service: rancher-server.service
