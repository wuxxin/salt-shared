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
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
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
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
      - pkgrepo: getdeb_ppa
{% endif %}


# vnc , rdp, ssh

remmina:
  pkg.installed:
    - pkgs:
      - remmina
      - remmina-plugin-vnc
      - remmina-plugin-gnome
      - remmina-plugin-rdp

