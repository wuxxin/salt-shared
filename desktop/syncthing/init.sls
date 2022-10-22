{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

{% load_yaml as defaults %}
paths: {}
bind: []
{% endload %}
{% set settings = salt['grains.filter_by']({'default': defaults},
  grain='default', default= 'default', merge= salt['pillar.get']('syncthing', {})) %}


syncthing:
{% if grains['os'] == 'Ubuntu' %}
  pkgrepo.managed:
    - name: deb https://apt.syncthing.net/ syncthing stable
    - file: /etc/apt/sources.list.d/syncthing.list
    - key_url: https://syncthing.net/release-key.txt
    - require_in:
      - pkg: syncthing
{% endif %}
  pkg.installed:
    - pkgs:
      - syncthing
      - bubblewrap

{{ user_home }}/.local/state/syncthing:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True

syncthing.service:
  file.managed:
    - name: {{ user_home }}/.config/systemd/user/syncthing.service
    - user: {{ user }}
    - group: {{ user }}
    - source: salt://desktop/syncthing/syncthing-bwrap.service
    - template: jinja
    - defaults:  
      settings: {{ settings }}
      user: {{ user }}
      user_info:  {{ user_info }}
      user_home: {{ user_home }}
