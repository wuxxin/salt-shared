{% if grains['os'] == 'Ubuntu' and grains['osrelease'] >= '14.04' :%}

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
  - .user
  - rbenv

local-ruby-{{ user }}:
  rbenv.installed:
    - name: ruby-2.0.0-p353
    - default: True
    - user: {{ user }}
    - require:
      - user: {{ user }}
      - pkg: rbenv-deps
  file.managed:
    - name: {{ user_home }}/.bash_profile
    - user: {{ user }}
    - group: {{ user }}
    - require: 
      - rbenv: local-ruby-{{ user }}

local-ruby-profile-{{ user }}:
  file.append:
    - name: /home/git/.bash_profile
    - text: |
        export PATH="$HOME/.rbenv/bin:$PATH"
        eval "$(rbenv init -)"
    - require:
      - file: local-ruby-{{ user }}

default-bundler-{{ user }}:
  pkg.installed:
    - name: bundler
    - require: 
      - cmd: local-ruby-profile-{{ user }}

default-ruby-{{ user }}:
  cmd.run:
    - name: "echo 'ok, default-ruby-{{ user }}'"
    - require:
      - pkg: default-bundler-{{ user }}

{% endif %} 
