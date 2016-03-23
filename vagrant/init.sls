{% set reqversion= "1.8.1"%}
{% set hash_32 = "ae93af8cacf20f2f8c4c6a111767e77988454d0238a001a37a1d1c115334efdb" %}
{% set hash_64 = "ed0e1ae0f35aecd47e0b3dfb486a230984a08ceda3b371486add4d42714a693d" %}

{% set actversion= salt['pkg.version']('vagrant') %}
{% if actversion == "" %}
  {% set newer_or_equal= 1 %}
{% else %}
  {% set newer_or_equal= salt['pkg.version_cmp']("1:"+reqversion, actversion) %}
{% endif %}

{% if newer_or_equal <= -1 %}
  {% set reqversion= actversion %}
{% endif %}


{% if grains.osarch == "amd64" %}
  {% set requrl = "https://releases.hashicorp.com/vagrant/"+ reqversion+ "/vagrant_"+ reqversion+ "_x86_64.deb" %}
  {% set localfile = "vagrant_"+ reqversion+ "_x86_64.deb" %}
  {% set hash = hash_64 %}
{% elif grains.osarch == "i386" %}
  {% set requrl = "https://releases.hashicorp.com/vagrant/"+ reqversion+ "/vagrant_"+ reqversion+ "_i686.deb" %}
  {% set localfile = "vagrant_"+ reqversion+ "_i686.deb" %}
  {% set hash = hash_32 %}
{% endif %}


{% if actversion != "" and newer_or_equal >= 1 %}

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
