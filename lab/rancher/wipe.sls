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

{% for i in ['/etc/rancher', '/etc/kubernetes', '/etc/cni', 
  '/var/lib/etcd', '/var/lib/cni', '/var/run/calico',
  '/opt/cni'] %}

{{ i }}:
  file:
    - absent
{% endfor %}

/var/lib/rancher:
  file:
    - absent

/var/lib/kublet:
  file:
    - absent
    
systemd_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - order: last
