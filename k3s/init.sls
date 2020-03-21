{% from "k3s/defaults.jinja" import settings %}

include:
  - kernel.server

{% if grains['virtual'] == 'LXC' %}
/etc/tmpfiles.d/kmsg.conf:
  file.managed:
    - contents: |
        # add symlink for missing kmsg to console
        L /dev/kmsg - - - - /dev/console
  cmd.run:
    - name: systemd-tmpfiles  --create
    - onchanges:
      - file: /etc/tmpfiles.d/kmsg.conf
    - require_in:
      - cmd: k3s
{% endif %}

{% if grains['virtual'] != 'LXC' %}
k3s-kernel-modules:
  kmod.present:
    - persist: true
    - mods:
      - overlay
      - ip_tables
      - ip6_tables
      - netlink_diag
      - nf_nat
      - xt_conntrack
      - br_netfilter
      - nf_conntrack
      - ip_vs
      - ip_vs_rr
      - ip_vs_wrr
      - ip_vs_sh
    - require_in:
      - cmd: k3s
{% endif %}


k3s-install:
  file.managed:
    - name: /usr/local/sbin/k3s-install.sh
    - source: https://raw.githubusercontent.com/rancher/k3s/master/install.sh
    - skip_verify: true
    - mode: "755"

k3s:
  pkg.installed:
    - pkgs:
      - thin-provisioning-tools
      - bridge-utils
      - ebtables
      - squashfs-tools
      - kubetail
      # criu
  file.managed:
    - name: /usr/local/bin/k3s
    - source: https://github.com/rancher/k3s/releases/download/v{{ settings.k3s_version }}/k3s
    - source_hash: https://github.com/rancher/k3s/releases/download/v{{ settings.k3s_version }}/sha256sum-amd64.txt
    - mode: "755"
  cmd.run:
    - name: /usr/local/sbin/k3s-install.sh
    - env:
      - INSTALL_K3S_VERSION: v{{ settings.k3s_version }}
      - INSTALL_K3S_EXEC: server --no-deploy=traefik --node-ip {{ settings.route_ip }} {% if settings.external_ip|d(false) %}{{ '--node-external-ip '+ settings.external_ip }}{% endif %}
    - onchanges:
      - file: k3s
    - require:
      - pkg: k3s
      - file: k3s
      - file: k3s-install

helm:
  file.managed:
    - name: /usr/local/lib/helm-linux-amd64.tar.gz
    - source: https://get.helm.sh/helm-v{{ settings.helm_version }}-linux-amd64.tar.gz
    - source_hash: https://get.helm.sh/helm-v{{ settings.helm_version }}-linux-amd64.tar.gz.sha256
    - mode: "755"
  cmd.run:
    - name: tar xzf /usr/local/lib/helm-linux-amd64.tar.gz --overwrite -C /usr/local/bin --strip-components=1 linux-amd64/helm 
    - onchanges:
      - file: helm

helmfile:
  file.managed:
    - name: /usr/local/bin/helmfile
    - source: https://github.com/roboll/helmfile/releases/download/v{{ settings.helmfile_version }}/helmfile_linux_amd64
    - skip_verify: true
    - mode: "755"
    
rio:
  file.managed:
    - name: /usr/local/bin/rio
    - source: https://github.com/rancher/rio/releases/download/v{{ settings.rio_version }}/rio-linux-amd64
    - source_hash: https://github.com/rancher/rio/releases/download/v{{ settings.rio_version }}/sha256sum-amd64.txt
    - mode: "755"

{% for d in ['.kube', '.local/bin', '.local/share'] %}
{{ settings.home }}/{{ d }}:
  file.directory:
    - makedirs: true
    - user: {{ settings.user }}
    - group: {{ settings.user }}
{% endfor %}

local_kube_config:
  file.copy:
    - source: /etc/rancher/k3s/k3s.yaml
    - name: {{ settings.home }}/.kube/config
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - filemode: "0600"
    - force: true
    - require:
      - file: {{ settings.home }}/.kube
      - cmd: k3s

{# helm plugin: helm x #}
helm-x-bin-dir:
  file.directory:
    - name: {{ settings.home }}/.cache/helm/plugins/https-github.com-mumoshu-helm-x/bin
    - makedirs: true
    - user: {{ settings.user }}
    - group: {{ settings.user }}
helm-x.tar.gz:
  file.managed:
    - name: {{ settings.home }}/.local/share/helm-x.tar.gz
    - source: https://github.com/mumoshu/helm-x/archive/v{{ settings.helmx_version }}.tar.gz
    - skip_verify: true
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - requires:
      - file: {{ settings.home }}/.local/share
  archive.extracted:
    - source: {{ settings.home }}/.local/share/helm-x.tar.gz
    - name: {{ settings.home }}/.cache/helm/plugins/https-github.com-mumoshu-helm-x
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - require:
      - file: helm-x.tar.gz
helm-x-symlink:
  file.symlink:
    - name: {{ settings.home }}/.local/share/helm/plugins/helm-x
    - target: {{ settings.home }}/.cache/helm/plugins/https-github.com-mumoshu-helm-x
    - makedirs: true
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - requires:
      - file: {{ settings.home }}/.local/share
helm-x-binary:
  file.managed:
    - name: {{ settings.home }}/.local/share/helm-x_linux_amd64.tar.gz
    - source: https://github.com/mumoshu/helm-x/releases/download/v{{ settings.helmx_version }}/helm-x_{{ settings.helmx_version }}_linux_amd64.tar.gz
    - source_hash: https://github.com/mumoshu/helm-x/releases/download/v{{ settings.helmx_version }}/helm-x_{{ settings.helmx_version }}_checksums.txt
    - requires:
      - file: {{ settings.home }}/.local/share
  cmd.run:
    - name: tar xzf {{ settings.home }}/.local/share/helm-x_linux_amd64.tar.gz --overwrite -C {{ settings.home }}/.cache/helm/plugins/https-github.com-mumoshu-helm-x/bin helm-x
    - runas: {{ settings.user }}
    - onchanges:
      - file: helm-x-binary

{# helm plugin: helm diff #}
helm-diff-bin-dir:
  file.directory:
    - name: {{ settings.home }}/.cache/helm/plugins/https-github.com-databus23-helm-diff/bin
    - makedirs: true
    - user: {{ settings.user }}
    - group: {{ settings.user }}
helm-diff:
  file.managed:
    - name: {{ settings.home }}/.local/share/helm-diff-linux.tar.gz
    - source: https://github.com/databus23/helm-diff/releases/download/v{{ settings.helmdiff_version }}/helm-diff-linux.tgz
    - skip_verify: true
  archive.extracted:
    - source: {{ settings.home }}/.local/share/helm-diff-linux.tar.gz
    - name: {{ settings.home }}/.cache/helm/plugins/https-github.com-databus23-helm-diff
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - requires:
      - file: helm-diff
helm-diff-symlink:
  file.symlink:
    - name: {{ settings.home }}/.local/share/helm/plugins/helm-x
    - target: {{ settings.home }}/.cache/helm/plugins/https-github.com-mumoshu-helm-x
    - makedirs: true
    - user: {{ settings.user }}
    - group: {{ settings.user }}
