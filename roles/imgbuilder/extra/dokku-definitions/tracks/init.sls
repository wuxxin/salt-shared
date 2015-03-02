{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}
{% set target= s.image_base+ "/templates/dokku/tracks" %}

tracks:
  git.latest:
    - name: https://github.com/TracksApp/tracks.git
    - target: {{ target }}
    - user: {{ s.user }}
  file.managed:
    - source: salt://roles/imgbuilder/extra/dokku-definitions/tracks/Procfile
    - name: {{ target }}/Procfile
    - user: {{ s.user }}
  cmd.run:
    - cwd: {{ target }}
    - user: {{ s.user }}
    - name: git config user.email "saltmaster@localhost" && git config user.name "Salt Master"

{{ target }}/Gemfile:
  pkg.installed:
    - name: libpq-dev
  file.append:
    - text: |
        gem "pg", group: :postgres
        gem "rails_12factor", group: :production
        gem "puma", group: :production
  cmd.run:
    - cwd: {{ target }}
    - name: bundle install --without mysql:sqlite:test:development:selenium
    - user: {{ s.user }}

{% for a in ['site.yml', 'database.yml'] %}
{{ target }}/config/{{ a }}:
  file.managed:
    - source: salt://roles/imgbuilder/extra/dokku-definitions/tracks/{{ a }}
    - user: {{ s.user }}
    - template: jinja
{% endfor %}

{{ target }}/.gitignore:
  file.comment:
    - regex: ^(config/site.yml)|(config/database.yml)
  cmd.run:
    - cwd: {{ target }}
    - name: git add Procfile config/site.yml config/database.yml && git commit -a -m "modified by salt"
    - user: {{ s.user }}
