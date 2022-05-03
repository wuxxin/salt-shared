include:
  - qemu

{% if grains['os'] == 'Manjaro' %}

libvirt:
  pkg.installed:
    - pkgs:
      - libvirt
      - libvirt-dbus
      - libvirt-python

{% elif grains['os'] == 'Ubuntu' %}

libvirt:
  pkg.installed:
    - pkgs:
  {%- if grains['osmajorrelease']|int < 18 %}
      - libvirt-bin
  {%- else %}
      - libvirt-clients
      - libvirt-daemon
      - libvirt-daemon-system
      - augeas-tools
  {%- endif %}
    - require:
      - sls: qemu
  service.running:
  {%- if grains['osmajorrelease']|int < 18 %}
    - name: libvirt-bin
  {%- else %}
    - name: libvirtd
  {%- endif %}
    - enable: True
    - require:
      - pkg: libvirt

{# XXX maybe also enable libnss-libvirt #}

{%- endif %}
