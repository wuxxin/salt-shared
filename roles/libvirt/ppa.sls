{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %}

{% if grains['os'] == 'Ubuntu' %}
{% if grains['lsb_distrib_codename'] == 'precise' %}
libvirt_ppa_ubuntu:
  pkgrepo.managed:
    - name: deb http://ppa.launchpad.net/miurahr/vagrant/ubuntu {{ grains['lsb_distrib_codename'] }} main
    - humanname: "Vagrant-kvm depends on recent libvirt/qemu/kvm."
    - file: /etc/apt/sources.list.d/miurahr-libvirt-qemu-kvm-{{ grains['lsb_distrib_codename'] }}.list
    - keyid: f6722a387a2c203e1cc2b3ae78844d12ffb4b2a2
    - keyserver: keyserver.ubuntu.com
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}
{% endif %}
