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
      - python3-guestfs
      - ssh-askpass-gnome
      - virt-viewer
      - spice-client-gtk
    - require:
      - sls: libvirt

virt-manager:
  pkg.installed:
    - pkgs:
      - virt-manager
    - require:
      - pkg: virt-tools
