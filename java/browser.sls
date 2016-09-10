include:
  - java

browser-java:
  pkg.installed:
{% if grains['lsb_distrib_codename'] == 'trusty' %}
    - name: icedtea-7-plugin
{% else %}
    - name: icedtea-8-plugin
{% endif %}
