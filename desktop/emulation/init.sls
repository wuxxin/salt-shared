include:
  - kernel.cgroup
  - libvirt
  - lxd
  - vagrant
  - vagrant.user
  
{% if grains['lsb_distrib_codename'] in ['trusty', 'xenial'] %}
getdeb_ppa:
  pkgrepo.managed:
    - name: deb http://archive.getdeb.net/ubuntu {{ grains['lsb_distrib_codename'] }}-getdeb apps
    - file: /etc/apt/sources.list.d/getdeb.list
    - key_url: http://archive.getdeb.net/getdeb-archive.key
    - require_in:
      - pkg: virt-manager
{% endif %}

qemu:
  pkg.installed:
    - pkgs:
      - qemu
    - require:
      - sls: kernel.cgroup

virt-tools:
  pkg.installed:
    - pkgs:
      - python-spice-client-gtk
      - python-gnomekeyring
      - python-guestfs
      - ssh-askpass
      - virt-viewer
      - spice-client-gtk

# xserver-xspice
virt-manager:
  pkg.installed:
    - pkgs:
      - virt-manager
    - require:
      - pkg: virt-tools

# vnc , rdp, ssh
remmina:
  pkg.installed:
    - pkgs:
      - remmina
      - remmina-plugin-vnc
      - remmina-plugin-gnome
      - remmina-plugin-rdp
