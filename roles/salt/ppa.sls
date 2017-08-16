{% from "roles/salt/defaults.jinja" import settings as s with context %}

{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu
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

{% elif grains['os'] == 'Ubuntu' %}

salt_ppa:
  pkgrepo.managed:
    - name: deb http://repo.saltstack.com/apt/ubuntu/{{ grains['osrelease'] }}/{{ grains['osarch'] }}/{{ s.install.rev }} main
    - file: /etc/apt/sources.list.d/salt_ppa.list
    - key_url: salt://roles/salt/files/SALTSTACK-GPG-KEY.pub
  cmd.run:
    - name: "true"
    - require:
      - pkgrepo: salt_ppa

{% endif %}

salt_nop:
  test:
    - nop
