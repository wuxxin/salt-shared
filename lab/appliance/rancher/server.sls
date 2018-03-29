include:
  - .common
  
{% from "lab/appliance/rancher/defaults.jinja" import settings with context %}

rancher-server-volume:
  docker_volume.present:
    - name: rancher-server-volume
    - driver: local
    - driver_opts:
       type: "none"
       device: "/data/rancher/server"
       o: "bind"
    - require:
      - sls: .common
    
rancher-server-image:
  docker_image.present:
    - name: rancher/server:{{ settings.server_tag }}
    - require:
      - sls: .common

rancher-server.service:
  file.managed:
    - source: salt://lab/appliance/rancher/rancher-server.service
    - name: /etc/systemd/system/rancher-server.service
    - template: jinja
    - context:
      settings: {{ settings }}
    - watch_in:
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
    - source: salt://lab/appliance/rancher/rancher-server-setup.sh
    - name: /usr/local/share/appliance/rancher-server-setup.sh
    - mode: "0755"
  cmd.run:
    - name: /usr/local/share/appliance/rancher-server-setup.sh
    - unless: test -e /app/etc/rancher-server.env
    - require:
      - service: rancher-server.service
