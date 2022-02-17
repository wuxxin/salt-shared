{% if grains['os_family'] == "Debian" %}

{% set reponame= "node_16" ~ settings.major~ ".x" %}
nodejs:
  pkgrepo.managed:
    - name: deb https://deb.nodesource.com/{{ reponame }} {{ grains['oscodename'] }} main
    - key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
    - file: /etc/apt/sources.list.d/nodesource.com.list
    - require_in:
      - pkg: nodejs
  pkg:
    - installed

{% else %}

nodejs:
  pkg:
    - installed

{% endif %}
