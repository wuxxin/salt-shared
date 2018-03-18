{% from "vagrant/defaults.jinja" import settings with context %}

{% set actversion= salt['pkg.version']('vagrant') %}
{% if actversion == "" %}
  {% set newer_or_equal= 1 %}
{% else %}
  {% set newer_or_equal= salt['pkg.version_cmp']("1:"+settings.version, actversion) %}
{% endif %}

{% if newer_or_equal <= -1 %}
  {% set reqversion= actversion %}
{% else %}
  {% set reqversion= settings.version %}
{% endif %}

{% if grains.osarch == "amd64" %}
  {% set requrl = "https://releases.hashicorp.com/vagrant/"+ reqversion+ "/vagrant_"+ reqversion+ "_x86_64.deb" %}
  {% set localfile = "vagrant_"+ reqversion+ "_x86_64.deb" %}
  {% set hash = settings.hash.amd64 %}
{% elif grains.osarch == "i386" %}
  {% set requrl = "https://releases.hashicorp.com/vagrant/"+ reqversion+ "/vagrant_"+ reqversion+ "_i686.deb" %}
  {% set localfile = "vagrant_"+ reqversion+ "_i686.deb" %}
  {% set hash = settings.hash.i386 %}
{% endif %}

{% if newer_or_equal >= 1 %}

vagrant:
  file.managed:
    - name: /tmp/{{ localfile }}
    - source: {{ requrl }}
    - source_hash: sha256={{ hash }}
  pkg.installed:
    - sources:
      - vagrant: /tmp/{{ localfile }}
{% else %}

vagrant:
  pkg.installed:
    - name: vagrant

{% endif %}
