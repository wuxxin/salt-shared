include:
  - .ppa

qemu:
  pkg.installed:
    - pkgs:
      - qemu
      - qemu-system
      - qemu-user
      - qemu-utils

virt-tools:
  pkg.installed:
    - pkgs:
      - python-spice-client-gtk
      - python-gnomekeyring
      - python-guestfs
      - ssh-askpass
      - virt-viewer
      - spice-client-gtk
      - spice-client
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: getdeb_ppa
{% endif %}

# xserver-xspice

virt-manager:
  pkg.installed:
    - pkgs:
      - virt-manager
    - require:
      - pkg: virt-tools
{% if grains['os'] == 'Ubuntu' %}
      - pkgrepo: getdeb_ppa
{% endif %}


