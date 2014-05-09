{% macro user_ruby(user, ruby, default=True) %}

{% set rubyver= '2.0.0-p353' if not ruby else ruby %}
{% set user_home= salt['user.info'](user)['home'] %}


local-ruby-{{ user }}:
  rbenv.installed:
    - name: ruby-{{ rubyver }}
    - default: {{ default }}
    - user: {{ user }}
    - require:
      - pkg: rbenv-deps
  file.managed:
    - name: {{ user_home }}/.profile
    - user: {{ user }}
    - group: {{ user }}
    - require: 
      - rbenv: local-ruby-{{ user }}

local-ruby-profile-{{ user }}:
  file.append:
    - name: /home/{{ user }}/.profile
    - text: |
        export PATH="$HOME/.rbenv/bin:$PATH"
        eval "$(rbenv init -)"
    - require:
      - file: local-ruby-{{ user }}

local-ruby-bundler-{{ user }}:
  gem.installed:
    - name: bundler
    - user: {{ user }}
    - require: 
      - file: local-ruby-profile-{{ user }}

default-ruby-{{ user }}:
  cmd.run:
    - name: "echo 'ok, default-ruby-{{ user }}'"
    - require:
      - gem: local-ruby-bundler-{{ user }}

{% endmacro %}
