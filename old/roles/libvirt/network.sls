{% from "roles/libvirt/defaults.jinja" import settings as s with context %} 

/etc/libvirt/qemu/networks/autostart:
  file.directory:
    - makedirs: True

{% for item, data in s.networks.iteritems() %}
/etc/libvirt/qemu/networks/{{ item }}.xml:
  file.managed:
    - contents: |
{{ data|indent(8, true) }}

/etc/libvirt/qemu/networks/autostart/{{ item }}.xml:
  file.symlink:
    - target: /etc/libvirt/qemu/networks/{{ item }}.xml
    - require:
      - file: /etc/libvirt/qemu/networks/{{ item }}.xml
{% endfor %}
