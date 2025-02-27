{% if grains['os_family'] == "Debian" %}

nodejs:
  pkgrepo.managed:
    - name: deb https://deb.nodesource.com/node_20.x/ {{ grains['oscodename'] }} main
    - key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
    - file: /etc/apt/sources.list.d/nodesource.com.list
    - require_in:
      - pkg: nodejs
      - pkg: npm
  pkg:
    - installed

{% elif grains['os'] == 'Manjaro' %}

nodejs:
  pkg.installed:
    - name: nodejs
    # - name: nodejs-lts-jod

{% endif %}

npm:
  pkg:
    - installed
