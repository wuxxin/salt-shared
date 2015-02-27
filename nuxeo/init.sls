include:
  - .ppa

nuxeo:
  pkg:
    - installed
{% if grains['os_family'] == 'Debian' %}
    - require:
      - pkgrepo: nuxeo_ppa
{% if grains['os'] == 'Ubuntu' %}
      - pkgrepo: olena_ppa
      - pkgrepo: ffmpeg_ppa
{% endif %}
{% endif %}
