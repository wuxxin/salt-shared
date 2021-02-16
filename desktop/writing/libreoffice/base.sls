include:
  - ubuntu
  - desktop.graphics.clipart.big
  - desktop.language.spellcheck

libreoffice:
  pkg.installed:
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
