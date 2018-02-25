include:
  - docker
  - appliance
  
{% from "lab/appliance/rancher/defaults.jinja" import settings with context %}

rancher-prerequisites:
  pkg.installed:
    - pkgs:
      - jq
      - wget
      - curl

{% from 'python/lib.sls' import pip2_install, pip3_install %}
{{ pip2_install('rancher-agent-registration') }}

rancher-server-volume:
  docker_volume.present:
    - name: rancher-server-volume
    - driver: local
    - driver_opts:
       type: "none"
       device: "/data/rancher/server"
       o: "bind"
    - require:
      - sls: docker
    
rancher-server-image:
  docker_image.present:
    - name: rancher/server:{{ settings.server_tag }}
    - require:
      - sls: docker

/etc/systemd/system/rancher-server.service:
  file.managed:
    - source: salt://lab/appliance/rancher/rancher-server.service
    - template: jinja
    - context:
      settings: {{ settings }}
    - watch_in:
      - cmd: systemd_reload

