include:
  - libvirt
  
{% if grains['lsb_distrib_codename'] in ['trusty', 'xenial'] %}
getdeb_ppa:
  pkgrepo.managed:
    - name: deb http://archive.getdeb.net/ubuntu {{ grains['lsb_distrib_codename'] }}-getdeb apps
    - file: /etc/apt/sources.list.d/getdeb.list
    - key_url: http://archive.getdeb.net/getdeb-archive.key
    - require_in:
      - pkg: virt-manager
{% endif %}


virt-tools:
  pkg.installed:
    - pkgs:
      - python-spice-client-gtk
      - python-gnomekeyring
      - python-guestfs
      - ssh-askpass
      - virt-viewer
      - spice-client-gtk
    - require:
      - sls: libvirt

# xserver-xspice
virt-manager:
  pkg.installed:
    - pkgs:
      - virt-manager
    - require:
      - pkg: virt-tools

virtualbricks:
  pkg.installed:
    - pkgs:
      - virtualbricks
      - ksmtuned
      - vde2
    - require:
      - sls: libvirt
