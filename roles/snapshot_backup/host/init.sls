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
{% from "roles/snapshot_backup/defaults.jinja" import settings with context %}
{% from "roles/snapshot_backup/host/lib.sls" import create_backup_vm, start_backup_vm with context %}

{% load_yaml as config %}
hostname: {{ settings.backup_vm_name }}
target: '{{ im_set.image_base }}/templates/imgbuilder/{{ settings.backup_vm_name }}'
username: {{ im_set.user }}
{% endload %}

{% if settings.backup_vm_name not in salt['virt.list']['local'] %}
    {{ create_backup_vm(config) }}
    {{ start_backup_vm(config.hostname) }}
{% endif %}

backup_vm_is_ready:
  cmd.run:
    - name: true
