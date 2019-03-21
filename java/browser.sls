include:
  - java

browser-java:
  pkg.installed:
{% if grains['osrelease_info'][0]|int <= 19 %}
    - name: icedtea-plugin
{% else %}
    - name: icedtea-netx
{% endif %}
    - require:
      - sls: java
