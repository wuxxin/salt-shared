{% from "k3s/defaults.jinja" import settings %}
{
include:
  - kernel.server

{%- if grains['virtual'] == 'LXC' %}
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
{%- endif %}

{%- if grains['virtual'] != 'LXC' %}
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
{%- endif %}


k3s-install:
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
    - source: https://github.com/rancher/k3s/releases/download/{{ settings.k3s_version }}/k3s
    - source_hash: https://github.com/rancher/k3s/releases/download/{{ settings.k3s_version }}/sha256sum-amd64.txt
    - mode: "755"
  cmd.run:
    - name: /usr/local/sbin/k3s-install.sh
    - env:
      - INSTALL_K3S_VERSION: {{ settings.k3s_version }}
      - INSTALL_K3S_EXEC: server --no-deploy=servicelb --no-deploy=traefik --node-ip {{ settings.route_ip }} --tls-san {{ settings.route_ip }} --bind-address {{ settings.route_ip }}
    - unless: test -e /etc/rancher/k3s/k3s.yaml
    - require:
      - sls: app.network
      - sls: app.hostname
      - pkg: k3s
      - file: k3s
      - file: k3s-install

helm:
  file.managed:
    - name: /usr/local/lib/helm-linux-amd64.tar.gz
    - source: https://get.helm.sh/helm-{{ settings.helm_version }}-linux-amd64.tar.gz
    - source_hash: https://get.helm.sh/helm-{{ settings.helm_version }}-linux-amd64.tar.gz.sha256
    - mode: "755"
  cmd.run:
    - name: tar xzf /usr/local/lib/helm-linux-amd64.tar.gz --overwrite -C /usr/local/bin --strip-components=1 linux-amd64/helm 
    - onchanges:
      - file: helm

helmfile:
  file.managed:
    - name: /usr/local/bin/helmfile
    - source: https://github.com/roboll/helmfile/releases/download/{{ settings.helmfile_version }}/helmfile_linux_amd64
    - skip_verify: true
    - mode: "755"
    
rio:
  file.managed:
    - name: /usr/local/bin/rio
    - source: https://github.com/rancher/rio/releases/download/{{ settings.rio_version }}/rio-linux-amd64
    - source_hash: https://github.com/rancher/rio/releases/download/{{ settings.rio_version }}/sha256sum-amd64.txt
    - mode: "755"

local_kube_config:
  file.copy:
    - makedirs: true
    - source: /etc/rancher/k3s/k3s.yaml
    - name: {{ settings.home }}/.kube/config
    - require:
      - sls: k3s
      
helm-x:
  cmd.run:
    - runas: {{ settings.user }}
    - name: helm plugin install https://github.com/mumoshu/helm-x
    - unless: helm plugin list | grep -q "^x "
    - requires:
      - file: local_kube_config
