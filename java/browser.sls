include:
  - java

browser-java:
  pkg.installed:
{% if grains['os'] == 'Ubuntu' and grains['osmajorrelease'] < 19 %}
    - name: icedtea-plugin
{% else %}
    - name: icedtea-netx
{% endif %}
    - require:
      - sls: java
