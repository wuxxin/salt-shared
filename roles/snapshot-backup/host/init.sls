include:
  - imgbuilder

snapshot_backup_host:
  pkg.installed:
    - pkgs:
      - lvm2
      - xmlstarlet

{% if salt['pillar.get']('snapshot_backup:custom_storage', false) %}
  {% from 'storage/lib.sls' import storage_setup with context %}
  {{ storage_setup(salt['pillar.get']('snapshot_backup:custom_storage')) }}
{% endif %}

{% from "roles/imgbuilder/defaults.jinja" import settings as im_set with context %}
{% from "roles/imgbuilder/vagrant/lib.sls" import deploy_vagrant_vm with context %}
{% from "roles/snapshot_backup/defaults.jinja" import settings with context %}

{% load_yaml as config %}
hostname: {{ settings.backup_vm_name }}
target: '{{ im_set.image_base }}/templates/imgbuilder/{{ settings.backup_vm_name }}'
username: {{ im_set.user }}
{% endload %}

{% set l = salt['virt.list_vms']()['local'] %}
{% if l is undefined or settings.backup_vm_name not in l %}

{% for a in ('Vagrantfile',) %}
backup_vm-copy-{{ a }}:
  file.managed:
    - source: "salt://roles/snapshot_backup/files/{{ a }}"
    - name: {{ config.target }}/{{ a }}
    - user: {{ im_set.user }}
    - group: {{ im_set.user }}
    - mode: 644
    - template: jinja
    - makedirs: True
    - context:
        target: {{ config.target }}
        hostname: {{ config.hostname|d(" ") }}
{% endfor %}

{{ deploy_vagrant_vm(config) }}

start_backup_vm:
  module.run:
    - name: virt.start
    - m_name: {{ config.hostname }}

{% endif %}

backup_vm_is_ready:
  cmd.run:
    - name: true
