include:
  - .ppa

qemu:
  pkg.installed:
    - pkgs:
      - qemu
      - qemu-system
      - qemu-user
      - qemu-utils

virt-manager:
  pkg.installed:
    - pkgs:
      - python-gnomekeyring
      - python-guestfs
      - python-spice-client-gtk
      - ssh-askpass
      - virt-viewer
      - virt-manager
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: getdeb_ppa
{% endif %}


