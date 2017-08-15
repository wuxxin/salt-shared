{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu
{% endif %}

{% if grains['os'] == 'Ubuntu' %}

dokku_ppa:
  pkgrepo.managed:
    - name: deb http://packagecloud.io/dokku/dokku/ubuntu/ trusty main
    - file: /etc/apt/sources.list.d/dokku-trusty.list
    - key_url: salt://roles/dokku/packagecloud.gpg.key
  cmd.run:
    - name: "true"
    - require:
      - pkgrepo: dokku_ppa

{% endif %}

dokku_nop:
  test:
    - nop
