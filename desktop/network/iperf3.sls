{# iperf3 is bitrotten on ubuntu/debian, download from source #}
{% load_yaml as iperfconfig %}
version: "3.1.3-1"
baseurl: https://iperf.fr/download/ubuntu/
packages: 
  - name: libiperf0
    hash:
      amd64: d27693e76321a3c835112f14e2e5dd6649b5c158747ff8b0f95d4be784ce14f8
      i386: bbfe484544e8ba80c2a128942a05808b563ebb3f6e076125dff5d9ce8e454ac4
  - name: iperf3
    hash:
      amd64: 56a53021c9053ad7b709cee3c684d8fab0a65c6cc7c236e0af59a5f6f19ef9c3
      i386: 36eb1498d79f3672bb31cc144e45bd8e18e18942ee2710f9b6aac7b6a6fe69a6
{% endload %}

{% set actversion= salt['pkg.version']('iperf3') %}
{% if actversion == "" %}
  {% set newer_or_equal= 1 %}
{% else %}
  {% set newer_or_equal= salt['pkg.version_cmp']("1:"+iperfconfig.version, actversion) %}
{% endif %}
{% if newer_or_equal <= -1 %}
  {% set reqversion= actversion %}
{% else %}
  {% set reqversion= iperfconfig.version %}
{% endif %}


{% for package in iperfconfig.packages %}
  {% set localfile = package.name+ "_"+ iperfconfig.version+ "_"+ grains.osarch+ ".deb" %}
  {% set requrl = iperfconfig.baseurl+ localfile %}
  {% set hash = package.hash[grains.osarch] %}

  {% if newer_or_equal >= 1 %}    
{{ package.name }}:
  file.managed:
    - name: /var/cache/apt/archives/{{ localfile }}
    - source: {{ requrl }}
    - source_hash: sha256={{ hash }}
  pkg.installed:
    - sources:
      - {{ package.name }}: /var/cache/apt/archives/{{ localfile }}
    - require:
      - file: {{ package.name }}

  {% else %}
{{ package.name }}:
  pkg:
    - installed
  {% endif %}
{% endfor %}

