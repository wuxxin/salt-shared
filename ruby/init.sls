{% if (grains['os'] == 'Ubuntu' and grains['osrelease'] >= '14.04') or (grains['os'] == 'Mint') %}

ruby:
  pkg.installed:
    - pkgs:
      - ruby2.0
      - ruby2.0-dev

default-ruby-1.9.1:
  cmd.run:
    - name: |
        update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 400 \
        --slave /usr/bin/gem gem /usr/bin/gem1.9.1 \
        --slave /usr/bin/ri ri /usr/bin/ri1.9.1 \
        --slave /usr/bin/erb erb /usr/bin/erb1.9.1 \
        --slave /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.1 \
        --slave /usr/bin/testrb testrb /usr/bin/testrb1.9.1 \
        --slave /usr/bin/irb irb /usr/bin/irb1.9.1

default-ruby-2.0: 
  cmd.run:
    - name: |
        update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby2.0 500 \
        --slave /usr/bin/gem gem /usr/bin/gem2.0 \
        --slave /usr/bin/ri ri /usr/bin/ri2.0 \
        --slave /usr/bin/erb erb /usr/bin/erb2.0 \
        --slave /usr/bin/rdoc rdoc /usr/bin/rdoc2.0 \
        --slave /usr/bin/testrb testrb /usr/bin/testrb2.0 \
        --slave /usr/bin/irb irb /usr/bin/irb2.0

update-default-ruby:
  cmd.run:
    - name: update-alternatives --auto ruby
    - require:
      - cmd: default-ruby-1.9.1
      - cmd: default-ruby-2.0
      - pkg: ruby

ruby-bundler:
  pkg.installed:
    - name: bundler
    - require: 
      - cmd: update-default-ruby

default-ruby:
  cmd.run:
    - name: "echo 'ok, default-ruby'"
    - require:
      - pkg: ruby-bundler

{% else %}

include:
  - rbenv

{% from "rbenv/lib.sls" import default_local_ruby with context %}
{{ default_local_ruby('root','') }}

default-ruby:
  cmd.run:
    - name: "echo 'ok, default-ruby via default-local-ruby-root'"
    - require:
      - cmd: default-local-ruby-root

{% endif %} 
