include:
  - kernel.network
  - qemu

libvirt:
  pkg.installed:
    - pkgs:
{% if grains['os'] == 'Manjaro' %}
      - libvirt
      - libvirt-dbus
      - libvirt-python
{% elif grains['os'] == 'Ubuntu' %}
      - libvirt-clients
      - libvirt-daemon
      - libvirt-daemon-system
{%- endif %}
    - require:
      - sls: kernel.network
      - sls: qemu
  service.running:
    - name: libvirtd
    - enable: True
    - require:
      - pkg: libvirt
