include:
  - kernel.kvm

libvirt:
  pkg.installed:
    - pkgs:
{%- if grains['os'] == 'Ubuntu' and grains['osmajorrelease']|int < 18 %}
      - libvirt-bin
{%- else %}
      - libvirt-clients
      - libvirt-daemon
      - libvirt-daemon-system
      - libvirt-daemon-driver-storage-zfs
      - augeas-tools
{%- endif %}
    - require:
      - sls: kernel.kvm
  service.running:
{%- if grains['os'] == 'Ubuntu' and grains['osmajorrelease']|int < 18 %}
    - name: libvirt-bin
{%- else %}
    - name: libvirtd
{%- endif %}
    - enable: True
    - require:
      - pkg: libvirt
