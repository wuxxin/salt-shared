fonts:
  pkg.installed:
    - pkgs:
      - fonts-dejavu
      - fonts-liberation
{% if grains['lsb_distrib_codename'] == 'trusty' %}
      - fonts-droid
{% else %}
      - fonts-droid-fallback
{% endif %}
      - fonts-lmodern
      - fonts-larabie-deco
      - fonts-larabie-straight
