include:
  - ubuntu
  - desktop.graphics.clipart
  - desktop.spellcheck

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("libreoffice-ppa", "libreoffice/libreoffice-6-0",
  require_in = "pkg:libreoffice") }}

libreoffice:
  pkg.latest:
    - pkgs:
      - libreoffice
      - fonts-noto-hinted
      - fonts-noto
      - imagemagick
      - ghostscript
      - gnupg
      - gpa
      - pstoedit
      - unixodbc

