{% import_yaml "python/defaults.yml" as defaults %}
{% set settings=salt['grains.filter_by']({'default': defaults}, grain='default', 
    default= 'default', merge= salt['pillar.get']('python', {})) %}

include:
  - python

ipython:
  pkg.installed:
    - pkgs: {{ settings.ipython[grains['os_family']|lower] }}
