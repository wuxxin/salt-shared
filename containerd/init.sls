{% from "containerd/defaults.jinja" import settings with context %}

include:
  - kernel.server

/etc/crictl.yaml:
  file.managed:
    - contents: |
{{ settings.crictl|json|indent(8,True) }}

/etc/containerd/containerd.conf:
  file.serialize:
    - dataset: {{ settings.config }}
    - formatter: toml
    - merge_if_exists: true
    - makedirs: true

cri-containerd-cni.tar.gz:
  file.managed:
    - source: {{ settings.external['cri-containerd-cni.tar.gz']['download'] }}
    - source_hash: {{ settings.external['cri-containerd-cni.tar.gz']['hash_url'] }}
    - name: {{ settings.external['cri-containerd-cni.tar.gz']['target'] }}
  archive.extracted:
    - name: /
    - source: {{ settings.external['cri-containerd-cni.tar.gz']['target'] }}
    - archive_format: tar
    - overwrite: true
    - clean: false
    - onchanges:
      - file: cri-containerd-cni.tar.gz

containerd.service:
  file.managed:
    - name: /etc/systemd/system/containerd.service
    - source: salt://containerd/containerd.service
    - require:
      - archive: cri-containerd-cni.tar.gz
