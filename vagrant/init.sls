{% from "vagrant/defaults.jinja" import settings with context %}

{% if settings.origin == 'upstream' %}
  {% set actversion= salt['pkg.version']('vagrant') %}
  {% if actversion == "" %}
    {% set newer_or_equal= 1 %}
  {% else %}
    {% set newer_or_equal= salt['pkg.version_cmp']("1:"+settings.upstream.version, actversion) %}
  {% endif %}
  {% if newer_or_equal <= -1 %}
    {% set reqversion= actversion %}
  {% else %}
    {% set reqversion= settings.upstream.version %}
  {% endif %}
  {% if grains.osarch == "amd64" %}
    {% set requrl = "https://releases.hashicorp.com/vagrant/"+ reqversion+ "/vagrant_"+ reqversion+ "_x86_64.deb" %}
    {% set localfile = "vagrant_"+ reqversion+ "_x86_64.deb" %}
    {% set hash = settings.upstream.hash.amd64 %}
  {% elif grains.osarch == "i386" %}
    {% set requrl = "https://releases.hashicorp.com/vagrant/"+ reqversion+ "/vagrant_"+ reqversion+ "_i686.deb" %}
    {% set localfile = "vagrant_"+ reqversion+ "_i686.deb" %}
    {% set hash = settings.upstream.hash.i386 %}
  {% endif %}
{% endif %}

vagrant-prerequisites:
  pkg.installed:
    - pkgs:
      - genisoimage
      - openssl
      - fakeroot
      - gnupg
      - xz-utils
      - xmlstarlet
      - qemu-utils
      - libguestfs-tools
    - require_in:
      - pkg: vagrant

/usr/local/share/vagrant/cloud-init-block.yaml:
  file.managed:
    - source: salt://vagrant/cloud-init-block.yaml
    - makedirs: true

{% for i in [
  'vagrant-box-add-ubuntu.sh',
  'create-cidata-iso.sh'
] %}
{{ i }}:
  file.managed:
    - source: salt://vagrant/{{ i }}
    - name: /usr/local/bin/{{ i }}
    - mode: "0755"
{% endfor %}

{% if settings.origin == 'upstream' and newer_or_equal|d(0) >= 1 %}
vagrant:
  file.managed:
    - name: /var/cache/apt/archives/{{ localfile }}
    - source: {{ requrl }}
    - source_hash: sha256={{ hash }}
  pkg.installed:
    - sources:
      - vagrant: /var/cache/apt/archives/{{ localfile }}
    - require:
      - file: vagrant
{% else %}
vagrant:
  pkg.installed:
    - name: vagrant
{% endif %}
