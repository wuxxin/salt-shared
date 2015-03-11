include:
  - roles.dokku

{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

{{ s.image_base }}/templates/dokku:
  file.directory:
    - user: {{ s.user }}
    - group: {{ s.user }}
    - mode: 775
    - makedirs: True
