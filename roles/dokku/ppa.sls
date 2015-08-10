{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %}

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}

dokku_ppa:
  pkgrepo.managed:
    - name: https://packagecloud.io/dokku/dokku/ubuntu/ trusty main
    - file: /etc/apt/sources.list.d/dokku-trusty.list
    - keyid: EAD883AF
    - keyserver: keys.gnupg.net
  cmd.run:
    - name: true
    - require:
      - cmd: dokku_ppa

{% endif %}
