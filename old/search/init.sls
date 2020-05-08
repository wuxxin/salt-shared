{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("recoll_ppa", "recoll-backports/recoll-1.15-on", require_in= "pkg: recoll") }}
{% endif %}

recoll:
  pkg.installed:
    - pkgs:
      - recoll
      - antiword
      - catdoc
      - ghostscript
      - libimage-exiftool-perl
      - poppler-utils
      - pstotext
      - python3-chm
      - python3-mutagen
      - unrtf
      - untex
