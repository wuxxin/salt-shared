
/etc/libvirt/qemu/networks:
  file.recurse:
    - source: {{ pillar.libvirt.networks if pillar['libvirt']['networks'] else 'salt://roles/libvirt/networks/' }}

#{% for n in salt['file.find']('/etc/libvirt/qemu/networks',name='*', types='f') %}
#/etc/libvirt/qemu/networks/autostart/{{ n }}:
#  file.symlink:
#    - target: /etc/libvirt/qemu/networks/{{ n }}
#    - require:
#      - file: /etc/libvirt/qemu/networks
#{% endfor %}

