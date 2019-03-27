include:
  - ubuntu
  - desktop.graphics.clipart.big
  - desktop.spellcheck

{#
/etc/apt/preferences.d/libreoffice-preferences:
  file.managed:
    - contents: |
        Package: libreoffice
        Pin: version 5.*
        Pin-Priority: 900
#}

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("libreoffice-ppa", "libreoffice/libreoffice-6-0",
  require_in = "pkg:libreoffice") }}

libreoffice:
  pkg.latest:
    - pkgs:
      - libreoffice
      - libreoffice-writer2xhtml
      - libreoffice-writer2latex
      - fonts-noto-core
      - fonts-noto-mono
      - fonts-noto-ui-core
      - graphicsmagick-imagemagick-compat
      - ghostscript
      - gnupg
      - gpa
      - pstoedit
      - unixodbc
      - unoconv   {# unattended libreoffice supported formats converter #}

