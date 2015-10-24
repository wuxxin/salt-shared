{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %}

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}

dokku_ppa:
  pkgrepo.managed:
    - name: deb https://packagecloud.io/dokku/dokku/ubuntu/ trusty main
    - file: /etc/apt/sources.list.d/dokku-trusty.list
    - key_url: salt://roles/dokku/packagecloud.gpg.key
  cmd.run:
    - name: true
    - require:
      - pkgrepo: dokku_ppa

{% endif %}
