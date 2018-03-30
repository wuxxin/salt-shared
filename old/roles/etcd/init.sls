include:
  - golang

{% from 'golang/lib.sls' import go_build_from_git with context %}

{% load_yaml as config %}
source:
  repo: 'https://github.com/coreos/etcd.git'
  rev: 'v2.0'
build:
  check: 'etcd'
  bin_files: ['etcd']
{% endload %}

{{ go_build_from_git(config) }}

