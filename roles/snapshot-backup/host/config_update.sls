{% from "roles/snapshot_backup/defaults.jinja" import settings as s with context %}

{{ s.config_base }}/clients.d:
  file.directory:
    - makedirs: True

{% if salt['pillar.get']('snapshot_backup:update:config:type', 'lvm_libvirt') = 'lvm_host' and 
      salt['pillar.get']('snapshot_backup:host:present', False) != True %} 
{# fixme: this should ask if the calling (signal emitting) vm is the one with snapshot_backup:host:present #}
config_error:
  cmd.run:
    - name: false
{% else %}

{% if salt['pillar.get']('snapshot_backup:update:status', 'absent') = 'present' %} 

{{ s.config_base }}/clients.d/{{ salt['pillar.get']('snapshot_backup:update:minion') }}:
  file.managed:
    - contents_pillar: "snapshot_backup:update:config"

{% else %}

{{ s.config_base }}/clients.d/{{ salt['pillar.get']('snapshot_backup:update:minion') }}:
  file.managed:
    - contents:
        absent: True


{% endif %}


{% endif %}
