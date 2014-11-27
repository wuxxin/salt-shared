include:
  - .init

{% macro go_build_from_git(build_config) %}

{# config:
source:
  repo:
  rev: 
build: 
  # salt['extutils.re_replace']('([a-z]+)://[([^@]@)?([^:]:[0-9]+)?/(.+)\.git', '\\4', config.source.repository)
  name: last part of \\4
  dir: default to: \\4
  rev: default to: config.source.rev
  make: defaults to: 'go build' + config.build.dir
  check:
  bin_files:
target:
  versiondir: /usr/local/src
  symlinkdir: /usr/local/bin
#}


{% from "golang/defaults.jinja" import defaults with context %}
{% set config=salt['grains.filter_by']({'none': defaults },
  grain='none', default= 'none', merge= build_config) %}

{% set home="/home/"+ config.user %}
{% set gopath=home+ "/go" %}
{% set target_versiondir= config.target.versiondir+ '/'+ config.build.name+ '-'+ config.build.rev+ '-'+
   grains['kernel']|lower+ '-'+ grains['osarch']|lower %}

go_profile:
  file.managed:
    - name: {{ home }}/.profile
    - user: {{ config.user }}
    - group: {{ config.user }}
    - require:
      - user: go_builder

go_profile-activate:
  file.append:
    - name: {{ home }}/.profile
    - text: |
        export GOPATH={{ gopath }}
        export PATH=${GOPATH}/bin:$PATH
    - require:
      - file: go_profile

go-build-{{ config.build.name }}:
  group:
    - present
    - name: {{ config.user }}
  user:
    - present
    - name: {{ config.user }}
    - gid: {{ config.user }}
    - home: {{ home }}
    - shell: /bin/bash
    - remove_groups: False
    - require:
      - group: go-build-{{ config.build.name }}
  file.directory:
    - name: {{ gopath }}/bin
    - user: {{ config.user }}
    - group: {{ config.user }}
    - mode: 755
    - makedirs: True
    - require:
      - user: go-build-{{ config.build.name }}
  git.latest:
    - name: {{ config.source.repo }}
{%- if config.source.rev is defined and config.source.rev != None %}
    - rev: {{ config.source.rev }}
{%- endif %}
    - target: {{ gopath }}/src/{{ config.build.dir }}
    - user: {{ config.user }}
    - submodules: True
    - require:
      - file: go-build-{{ config.build.name }}
      - pkg: golang
  cmd.wait:
    - cwd: {{ gopath }}/bin
    - env:
      - GOPATH: "{{ gopath }}"
    - name: {{ config.build.make }} {{ config.build.dir }}
    - user: {{ config.user }}
    - group: {{ config.user }}
    - onlyif:
      - test ! -f {{ target_versiondir}}/{{ config.build.name }}
    - watch:
      - git: go-build-{{ config.build.name }}

{% for n in config.build.bin_files %}
go-deploy-{{ config.build.name }}-{{ n }}:
  file.copy:
    - name: {{ target_versiondir }}/{{ config.build.name }}/{{ n }}
    - source: {{ gopath }}/bin/{{ n }}
    - makedirs: true
    - watch:
      - cmd: go-build-{{ config.build.name }}

go-deploy-{{ config.build.name }}-symlink-{{ n }}:
  file.symlink:
    - name: {{ config.target.symlinkdir }}/{{ n }}
    - target: {{ target_versiondir }}/{{ config.build.name }}/{{ n }}
    - force: true
    - require:
      - file: go-deploy-{{ config.build.name }}-{{ n }}
{% endfor %}

{% endmacro %}
