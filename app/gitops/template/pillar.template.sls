{% from 'node.sls' import config %}

ssh_authorized_keys:
{% for key in config.ssh_authorized_keys.split("\n") %}
  - "{{ key}}"
{% endfor %}

ssh_deprecated_keys:

node:
  hostname: {{ config.node.hostname }}
  users:
    - name: {{ config.node.firstuser }}
      use_authorized_keys: true

  locale:
    lang: de_AT.UTF-8
    language: de_de:de
    timezone: Europe/Vienna

  network:
    internal: {{ config.network.internal }}
    netplan: {% if config.network.netplan == "" %}{}{% else %}
      default.yaml: |
{{ config.network.netplan|indent(8, True) }}{% endif %}
    networkmanager: {% if config.network.networkmanager == "" %}{}{% else %}
      default-lan.nmconnection: |
{{ config.network.networkmanager|indent(8, True) }}{% endif %}
    systemd: {% if config.network.systemd == "" %}{}{% else %}
      default.network: |
{{ config.network.systemd|indent(8, True) }}{% endif %}

gitops:
  user: {{ config.gitops_user }}
  home_dir: {{ config.gitops_target }}
  git:
    source: {{ config.node.gitops_source }}
    branch: {{ config.node.gitops_branch|d('main') }}
    gpg_id: |
{{ config.gitops_gpg_secret|indent(6,True)}}
    ssh_id: |
{{ config.gitops_ssh_secret|indent(6,True)}}
    ssh_id_pub: |
{{ config.gitops_ssh_public|indent(6,True)}}
    ssh_known_hosts: |
{{ config.gitops_known_hosts|indent(6, True) }}
