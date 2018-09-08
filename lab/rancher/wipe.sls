{% from "lab/rancher/defaults.jinja" import settings with context %}

#fixme evacuate node first

rancher-agent:
  service.dead:
    - enable: false
  file.absent:
    - name: /etc/systemd/system/rancher-agent.service

rancher-server:
  service.dead:
    - enable: false
  file.absent:
    - name: /etc/systemd/system/rancher-server.service

rancher-server-volume:
  docker_volume:
    - absent

/etc/rancher:
  file:
    - absent

/etc/kubernetes:
  file:
    - absent

systemd_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - order: last
