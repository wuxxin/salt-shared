
{# iperf2 is bitrotten on ubuntu/debian, download and compile from source #}
{% load_yaml as iperfconfig %}
version: "2.0.10"
name: iperf
baseurl: https://netcologne.dl.sourceforge.net/project/iperf2/
hash: 7fe4348dcca313b74e0aa9c34a8ccd713b84a5615b8578f4aa94cedce9891ef2
{% endload %}

iperf:
  file.managed:
    - name: /usr/local/src/{{ localfile }}
    - source: {{ requrl }}
    - source_hash: sha256={{ hash }}
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

