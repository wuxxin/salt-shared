
libvirtd:
  pkg.installed:
    - pkgs:
      - ubuntu-virt-server
      - libvirt-bin
      - qemu-kvm
      - virt-viewer
      - virt-manager
      - virtinst
      - virt-top
      - python-libvirt
      - python-spice-client-gtk
      - python-guestfs
      - libguestfs-tools

      - nbdkit
      - lvm2
      - multipath-tools
      - bridge-utils
      - vlan
      - nfs-common
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: libvirt_ppa_ubuntu
{% endif %}
  group.present:
    - require:
      - pkg: libvirtd
#  libvirt.keys:
#    - require:
#      - group: libvirtd

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

