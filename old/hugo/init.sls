include:
  - golang

{% from 'golang/lib.sls' import go_build_from_git with context %}

{% load_yaml as config %}
source:
  repo: 'https://github.com/spf13/hugo.git'
  rev: ''
build:
  check: 'hugo'
  bin_files: ['hugo']
{% endload %}

hugo:
  pkg.installed:
    - pkgs:
      - python-pygments

{{ go_build_from_git(config) }}

