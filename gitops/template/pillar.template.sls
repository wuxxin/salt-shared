{% from 'config.sls' import config %}

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
    additional: de_DE en_US en_GB
    messages: POSIX
    timezone: Europe/Vienna
    location: Vienna

  network:
    netplan: |
{{ config.network.netplan|indent(8, True) }}

gitops:
  user: {{ config.gitops_user }}
  home_dir: {{ config.gitops_target }}
  git:
    source: {{ config.node.gitops_source }}
    branch: {{ config.node.gitops_branch|d('master') }}
    gpg_id: |
{{ config.gitops_gpg_secret|indent(8,True)}}
    ssh_id: |
{{ config.gitops_ssh_secret|indent(8,True)}}
    ssh_id_pub: |
{{ config.gitops_ssh_public|indent(8,True)}}
    ssh_known_hosts: |
{{ config.gitops_known_hosts|indent(8, True) }}
