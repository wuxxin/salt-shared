{% from "roles/libvirt/defaults.jinja" import settings as s with context %} 

/etc/libvirt/storage/autostart:
  file.directory:
    - makedirs: True

{% for item, data in s.storage.iteritems() %}
/etc/libvirt/storage/{{ item }}.xml:
  file.managed:
    - contents: "{{ data }}"

/etc/libvirt/storage/autostart/{{ item }}.xml:
  file.symlink:
    - target: /etc/libvirt/storage/{{ item }}.xml
    - require:
      - file: /etc/libvirt/storage/{{ item }}.xml
{% endfor %}

{% if s.custom_storage is defined %}
{% from 'storage/lib.sls' import storage_setup with context %}
{{ storage_setup(s.custom_storage) }}
{% endif %}
