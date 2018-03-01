fonts:
  pkg.installed:
    - pkgs:
      - fonts-dejavu
{% if grains['osrelease_info'][0]|int <= 17 and 
    grains['osrelease'] != '17.10' %}
      - fonts-liberation
{% else %}  
      - fonts-liberation2
{% endif %}

{% if grains['lsb_distrib_codename'] == 'trusty' %}
      - fonts-droid
{% else %}
      - fonts-droid-fallback
{% endif %}
      - fonts-lmodern
      - fonts-larabie-deco
      - fonts-larabie-straight
  