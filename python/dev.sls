{% import_yaml "python/defaults.yml" as defaults %}
{% set settings=salt['grains.filter_by']({'default': defaults}, grain='default', 
    default= 'default', merge= salt['pillar.get']('python', {})) %}
{% from 'python/lib.sls' import pip_install %}

include:
  - python

ipython:
  pkg.installed:
    - pkgs: {{ settings.ipython[grains['os_family']|lower] }}

{% if grains['os_family']|lower == 'arch' %}

python-build-essentials:
  pkg.group_installed:
    - name: base-devel

{% endif %}

python-dev:
  pkg.installed:
    - pkgs: {{ settings.python_dev[grains['os_family']|lower] }}

{% if grains['os'] == 'Ubuntu' %}

meson-req:
  pkg.installed:
    - name: ninja-build

{{ pip_install('meson', require= 'pkg: meson-req') }}

{% endif %}
