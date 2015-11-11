{% from "roles/salt/defaults.jinja" import settings as s with context %}

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %}


{% if grains['os'] == 'Debian' %}
salt_ppa:
  pkgrepo.managed:
    - name: deb http://repo.saltstack.com/apt/debian/{{ s.install.rev }} {{ grains['lsb_distrib_codename'] }} main
    - file: /etc/apt/sources.list.d/salt_ppa.list
    - key_url: salt://roles/salt/files/SALTSTACK-GPG-KEY.pub
  cmd.run:
    - name: "true"
    - require:
      - pkgrepo: salt_ppa

{% elif (grains['os'] == 'Ubuntu' and grains['osrelease_info'][0] in [12,14] ) or grains['os'] == 'Mint' %}

{% set os_major= grains['osrelease_info'][0] if grains['os'] == 'Ubuntu' else '14' %}
{% set os_codename= grains['lsb_distrib_codename'] if grains['os'] == 'Ubuntu' else 'trusty' %}

salt_ppa:
  pkgrepo.managed:
    - name: deb http://repo.saltstack.com/apt/ubuntu/ubuntu{{ os_major }}/{{ s.install.rev }} {{ os_codename }} main
    - file: /etc/apt/sources.list.d/salt_ppa.list
    - key_url: salt://roles/salt/files/SALTSTACK-GPG-KEY.pub
  cmd.run:
    - name: "true"
    - require:
      - pkgrepo: salt_ppa

{% endif %}
