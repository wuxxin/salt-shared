
{# iperf2 is bitrotten on ubuntu/debian, download and compile from source #}
{% load_yaml as iperfconfig %}
version: "2.0.12"
name: iperf
baseurl: https://netcologne.dl.sourceforge.net/project/iperf2/
hash: 367f651fb1264b13f6518e41b8a7e08ce3e41b2a1c80e99ff0347561eed32646
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

