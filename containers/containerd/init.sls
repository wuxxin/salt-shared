{% from "containers/defaults.jinja" import settings with context %}

include:
  - kernel.server

/etc/containers:
  file:
    - directory

cri-containerd-cni.tar.gz:
  file.managed:
    - source: {{ settings.external['cri-containerd-cni.tar.gz']['download'] }}
    - source_hash: {{ settings.external['cri-containerd-cni.tar.gz']['hash_url'] }}
    - name: {{ settings.external['cri-containerd-cni.tar.gz']['target'] }}
