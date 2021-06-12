{% from "k3s/defaults.jinja" import settings with context %}

{# modify kernel settings for server workload #}
{# use external containerd to gain more customization possibilities, eg. using zfs #}

include:
  - kernel.server
  - containerd

{% if grains['virtual']|lower in ['lxc', 'systemd-nspawn'] %}
{# lxc and nspawn do not have kmsg available, symlink to console #}
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
      - service: k3s
{% endif %}

k3s.env:
  file.managed:
    - name: {{ settings.env_file }}
    - mode: 600
    - contents: |
{%- if salt['pillar.get']('http_proxy')|d(false) %}
        http_proxy="{{ salt['pillar.get']('http_proxy') }}"
        HTTP_PROXY="{{ salt['pillar.get']('http_proxy') }}"
{%- endif %}
{%- if salt['pillar.get']('https_proxy')|d(false) %}
        https_proxy="{{ salt['pillar.get']('https_proxy') }}"
        HTTPS_PROXY="{{ salt['pillar.get']('https_proxy') }}"
{%- endif %}
{%- if salt['pillar.get']('no_proxy')|d(false) %}
        no_proxy="{{ salt['pillar.get']('no_proxy', default_no_proxy) }}"
        NO_PROXY="{{ salt['pillar.get']('no_proxy', default_no_proxy) }}"
{%- endif %}

k3s.config:
  file.serialize:
    - name: {{ settings.k3s_config_file }}
    - dataset: {{ settings.config }}
    - formatter: yaml
    - makedirs: true

k3s.tools:
  pkg.installed:
    - pkgs:
      - kubetail

k3s.binary:
  file.managed:
    - name: {{ settings.external.k3s.target }}
    - source: {{ settings.external.k3s.download }}
    - source_hash: {{ settings.external.k3s.hash_url }}
    - mode: "755"
    - require:
      - sls: kernel.server
      - pkg: k3s.tools

k3s.service:
  file.managed:
    - name: /etc/systemd/system/k3s.service
    - source: salt://k3s/k3s.service
    - defaults:
        settings: {{ settings }}
    - template: jinja
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: k3s.service
  service.running:
    - enable: true
    - require:
      - sls: containerd
    - watch:
      - file: k3s.env
      - file: k3s.config
      - file: k3s.binary
      - file: k3s.service

{%- if settings.admin['copy-kubeconfig'] %}
  {%- set admin_home= salt['user.info'](settings.admin.user)['home'] %}
admin.kube.config:
  file.copy:
    - source: {{ settings.config['write-kubeconfig'] }}
    - name: {{ admin_home }}/.kube/config
    - user: {{ settings.admin.user }}
    - group: {{ settings.admin.user }}
    - filemode: "0600"
    - dirmode: "0700"
    - makedirs: true
    - force: true
    - require:
      - service: k3s.service
{%- endif %}
