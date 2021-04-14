{% from "old/roles/salt/defaults.jinja" import settings as s with context %}

{% if grains['os'] == 'Debian' %}
salt_ppa:
  pkgrepo.managed:
    - name: deb http://repo.saltstack.com/apt/debian/{{ s.install.rev }} {{ grains['oscodename'] }} main
    - file: /etc/apt/sources.list.d/salt_ppa.list
    - key_url: salt://old/roles/salt/files/SALTSTACK-GPG-KEY.pub

{% elif grains['os'] == 'Ubuntu' %}

salt_ppa:
  pkgrepo.managed:
    - name: deb http://repo.saltstack.com/apt/ubuntu/{{ grains['osrelease'] }}/{{ grains['osarch'] }}/{{ s.install.rev }} {{ grains['oscodename'] }} main
    - file: /etc/apt/sources.list.d/salt_ppa.list
    - key_url: salt://old/roles/salt/files/SALTSTACK-GPG-KEY.pub

{% endif %}

salt_nop:
  test:
    - nop
