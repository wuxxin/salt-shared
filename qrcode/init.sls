include:
  - python

qrcode:
  pkg.installed:
    - pkgs:
      - qrencode
      - imagemagick
      - zbar-tools

{% for a in ['data2qrpdf.sh', 'qrpdf2data.sh'] %}
/usr/local/bin/{{ a}}:
  file.managed:
    - source: salt://qrcode/{{ a }}
    - mode: "0755"
{% endfor %}
