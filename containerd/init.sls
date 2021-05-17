{% from "containerd/defaults.jinja" import settings with context %}

include:
  - kernel.server

/etc/crictl.yaml:
  file.serialize:
    - dataset: {{ settings.crictl }}
    - formatter: yaml

/etc/containerd/config.toml:
  file.serialize:
    - dataset: {{ settings.config }}
    - formatter: toml
    - merge_if_exists: true
    - makedirs: true

{% for key, item in settings.cni.items() %}
"cni_{{ key }}":
  file.serialize:
    - name: /etc/cni/net.d/net.d/{{ key }}.conflist
    - dataset: {{ item }}
    - formatter: json
    - makedirs: true
    - watch_in:
      - service: containerd.service
{% endfor %}

nerdctl.tar.gz:
  file.managed:
    - source: {{ settings.external['nerdctl.tar.gz']['download'] }}
    - source_hash: {{ settings.external['nerdctl.tar.gz']['hash_url'] }}
    - name: {{ settings.external['nerdctl.tar.gz']['target'] }}
  archive.extracted:
    - name: /usr/local/bin
    - source: {{ settings.external['nerdctl.tar.gz']['target'] }}
    - enforce_toplevel: false
    - archive_format: tar
    - overwrite: true
    - clean: false
    - onchanges:
      - file: nerdctl.tar.gz

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
    - enforce_toplevel: false
    - options: --exclude=/etc
    - clean: false
    - onchanges:
      - file: cri-containerd-cni.tar.gz

containerd.service:
  file.managed:
    - name: /etc/systemd/system/containerd.service
    - source: salt://containerd/containerd.service
    - require:
      - archive: cri-containerd-cni.tar.gz
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: containerd.service
  service.running:
    - enable: true
    - reload: true
    - require:
      - cmd: containerd.service
    - watch:
      - file: /etc/crictl.yaml
      - file: /etc/containerd/config.toml
