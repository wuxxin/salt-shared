include:
  - .init

{% macro go_build_from_git(build_config) %}

{# config:
source:
  repo:
  rev: 
build: 
  # salt['extutils.re_replace']('([a-z]+)://[([^@]@)?([^:]:[0-9]+)?/(.+)\.git', '\\4', config.source.repo)
  name: default: last part of \\4
  dir: default: \\4
  rev: default: config.source.rev
  make: default: 'go build' + config.build.dir
  check: 
  bin_files: []
target:
  versiondir: /usr/local/src
  symlinkdir: /usr/local/bin
#}


{% from "golang/defaults.jinja" import defaults with context %}
{% set config=salt['grains.filter_by']({'none': defaults },
  grain='none', default= 'none', merge= build_config) %}

{% set gitrepo_regex='([a-z]+)://([^@]+@)?([^:/]+)(:[0-9]+)?/(.+)\.git' %}
{% set dir_from_git= salt['extutils.re_replace'](gitrepo_regex, '\\3/\\5', config.source.repo) %}

{% if config.build.dir is none %} {% do config.build.update({'dir': dir_from_git}) %}{% endif %}
{% if config.build.name is none %}{% do config.build.update({'name': dir_from_git.split('/')[-1]}) %}{% endif %}
{% if config.build.rev is none %} {% do config.build.update({'rev': config.source.rev}) %}{% endif %}
{% if config.build.make is none %}{% do config.build.update({'make': 'go build ' + config.build.dir}) %}{% endif %}

{% set home="/home/"+ config.user %}
{% set gopath=home+ "/go" %}
{% set target_versiondir= config.target.versiondir+ '/'+ config.build.name+ '-'+ config.build.rev+ '-'+
   grains['kernel']|lower+ '-'+ grains['osarch']|lower %}

go_profile-{{ config.build.name }}:
  file.managed:
    - name: {{ home }}/.profile
    - user: {{ config.user }}
    - group: {{ config.user }}
    - require:
      - user: go-build-{{ config.build.name }}

go_profile-activate-{{ config.build.name }}:
  file.append:
    - name: {{ home }}/.profile
    - text: |
        export GOPATH={{ gopath }}
        export PATH=${GOPATH}/bin:$PATH
    - require:
      - file: go_profile-{{ config.build.name }}

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
{%- if config.source.rev is defined and config.source.rev != none %}
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
    - name: {{ config.build.make }}
    - user: {{ config.user }}
    - group: {{ config.user }}
    - onlyif:
      - test ! -f {{ target_versiondir}}/{{ config.build.name }}
    - require:
      - file: go_profile-activate-{{ config.build.name }}
    - watch:
      - git: go-build-{{ config.build.name }}

{% for n in config.build.bin_files %}
"go-deploy-{{ config.build.name }}-{{ n }}":
  cmd.run:
    - name: |
        if test ! -d {{ target_versiondir }}; then 
            mkdir -p {{ target_versiondir }}
        fi
        cp -a -f -t {{ target_versiondir }} {{ gopath }}/bin/{{ n }}
    - watch:
      - cmd: go-build-{{ config.build.name }}
    - require_in:
      - cmd: "go-deploy-{{ config.build.name }}-symlinks"
{% endfor %}

go-deploy-{{ config.build.name }}-symlinks:
  cmd.run:
    - name: |
        for n in `ls {{ target_versiondir }}`; do 
            ln -s -f -T {{ target_versiondir }}/$n {{ config.target.symlinkdir }}/$n
        done
    - watch:
      - cmd: go-build-{{ config.build.name }}

{% endmacro %}
