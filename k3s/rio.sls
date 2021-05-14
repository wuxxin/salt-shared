{% from "k3s/defaults.jinja" import settings %}

rio:
  file.managed:
    - name: /usr/local/bin/rio
    - source: https://github.com/rancher/rio/releases/download/v{{ settings.rio_version }}/rio-linux-amd64
    - source_hash: https://github.com/rancher/rio/releases/download/v{{ settings.rio_version }}/sha256sum-amd64.txt
    - mode: "755"
