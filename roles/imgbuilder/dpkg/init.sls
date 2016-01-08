{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

git-dpkg:
  pkg.installed:
    - pkgs:
      - pbuilder
      - cowbuilder
      - cowdancer
      - gdebi-core
      - git-buildpackage

{{ s.image_base }}/templates/git-dpkg:
  file.directory:
    - user: {{ s.user }}
    - group: {{ s.user }}
    - mode: 775
    - makedirs: True

base.cow:
  cmd.run:
    - name: cowbuilder --create --distribution trusty --components="main universe multivers
    e"
    - unless: test -f /var/cache/pbuilder/base.qcow
    
