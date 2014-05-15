
stopped_libvirt_bin:
  service.dead:
    - name: libvirt-bin
    - order: 51
    - require:
      - pkg: libvirtd

started_libvirt_bin:
  service.running:
    - name: libvirt-bin
    - order: 52
    - require:
      - pkg: libvirtd

/etc/libvirt/qemu/networks:
  file.recurse:
    - source: {{ pillar.libvirt.networks if pillar['libvirt']['networks'] else 'salt://roles/libvirt/networks/' }}
    - prereq_in:
      - service: stopped_libvirt_bin

#{% for n in salt['file.find']('/etc/libvirt/qemu/networks',name='*', types='f') %}
#/etc/libvirt/qemu/networks/autostart/{{ n }}:
#  file.symlink:
#    - target: /etc/libvirt/qemu/networks/{{ n }}
#    - require:
#      - file: /etc/libvirt/qemu/networks
#{% endfor %}

