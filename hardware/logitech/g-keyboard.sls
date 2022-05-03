{# Logitech Gxxx Keyboards #}

{% load_yaml as defaults %}
profile: |
  # Sample profile
  a 606060
  g logo 000000
  c # Commit changes
{% endload %}

{%- set settings = salt['grains.filter_by']({'default': defaults},
  grain='default', default= 'default', merge= salt['pillar.get']('logitech:g-keyboard', {})) %}

/etc/g810-led/profile:
  file.managed:
    - contents: |
{{ settings.profile|indent(8, True)}}

{% if grains['os'] == 'Manjaro' %}
g810-led-git:
  pkg:
    - installed

{% elif grains['os'] == 'Ubuntu' %}
  {% if grains['osmajorrelease']|int > 18 %}
g810-led:
  pkg:
    - installed

  {% else %}
g810-dependencies:
  pkg.installed:
    - pkgs:
      - build-essential
      - libhidapi-dev
g810-led:
  git.latest:
    - name: https://github.com/MatMoul/g810-led.git
    - target: /usr/local/src/g810-led
    - require:
      - pkg: g810-dependencies
  cmd.run:
    - name: make bin && make install
    - cwd: /usr/local/src/g810-led
  {% endif %}

{% endif %}
