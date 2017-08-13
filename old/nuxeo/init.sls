include:
  - .ppa

nuxeo:
  pkg:
    - installed
{% if grains['os_family'] == 'Debian' %}
    - require:
      - cmd: nuxeo_ppa
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
      - cmd: ffmpeg_ppa
{% endif %}
{% endif %}
