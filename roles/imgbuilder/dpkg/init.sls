{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

git-dpkg:
  pkg.installed:
    - pkgs:
      - pbuilder
      - cowdancer
      - gdebi-core
      - git-buildpackage

{{ s.image_base }}/templates/git-dpkg:
  file.directory:
    - user: {{ s.user }}
    - group: {{ s.user }}
    - mode: 775
    - makedirs: True
