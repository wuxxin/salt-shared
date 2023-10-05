{%- if grains['osmajorrelease']|int >= 18 %}

iperf:
  pkg.installed:
    - name: iperf

{%- else %}

{# iperf2 is bitrotten, download and compile from source #}
{% load_yaml as iperfconfig %}
version: "2.0.13"
name: iperf
baseurl: https://netcologne.dl.sourceforge.net/project/iperf2/
hash: c88adec966096a81136dda91b4bd19c27aae06df4d45a7f547a8e50d723778ad
{% endload %}
{% set localfile= iperfconfig.name+ '-'+ iperfconfig.version+ '.tar.gz' %}
{% set requrl= iperfconfig.baseurl+ localfile %}

iperf:
  file.managed:
    - name: /usr/local/src/{{ localfile }}
    - source: {{ requrl }}
    - source_hash: sha256={{ iperfconfig.hash }}
  archive.extracted:
    - name: /usr/local/src/
    - source: /usr/local/src/{{ localfile }}
    - onchanges:
      - file: iperf
  cmd.run:
    - name: ./configure && make && make install
    - cwd: /usr/local/src/{{ iperfconfig.name+ "-"+ iperfconfig.version }}
    - onchanges:
      - archive: iperf

{%- endif %}
