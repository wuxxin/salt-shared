{% from "k3s/defaults.jinja" import settings %}

include:
  - kernel.server
  - k3s.helm

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

rio:
  file.managed:
    - name: /usr/local/bin/rio
    - source: https://github.com/rancher/rio/releases/download/v{{ settings.rio_version }}/rio-linux-amd64
    - source_hash: https://github.com/rancher/rio/releases/download/v{{ settings.rio_version }}/sha256sum-amd64.txt
    - mode: "755"
