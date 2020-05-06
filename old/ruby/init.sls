{% if (grains['os'] == 'Ubuntu' and grains['oscodename'] == 'trusty') %}

include:
  - .rbenv

{% from "ruby/rbenv/lib.sls" import default_local_ruby with context %}
{{ default_local_ruby('root','') }}

default-ruby:
  cmd.run:
    - name: "echo 'ok, default-ruby via default-local-ruby-root'"
    - require:
      - cmd: default-local-ruby-root

{% else %}

ruby:
  pkg.installed:
    - pkgs:
      - rub
      - ruby-dev

ruby-bundler:
  pkg.installed:
    - name: bundler
    - require:
      - pkg: ruby

default-ruby:
  cmd.run:
    - name: "echo 'ok, default-ruby'"
    - require:
      - pkg: ruby-bundler

{% endif %} 
