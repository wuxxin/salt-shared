include:
  - .user
  - rbenv

local-ruby:
  rbenv.installed:
    - name: ruby-2.0.0-p353
    - default: True
    - user: imgbuilder
    - require:
      - user: imgbuilder
      - pkg: rbenv-deps
  file.managed:
    - name: /home/imgbuilder/.bash_profile
    - user: imgbuilder
    - group: imgbuilder
    - require: 
      - rbenv: local-ruby

rbenv-activate:
  file.append:
    - name: /home/imgbuilder/.bash_profile
    - text: |
        export PATH="$HOME/.rbenv/bin:$PATH"
        eval "$(rbenv init -)"
    - require:
      - file: local-ruby




