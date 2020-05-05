include:
  - tools

terminal-tools:
  pkg.installed:
    - pkgs:
      - dbview
      - file
      - odt2txt
      - poppler-utils
      - evince
      - img2pdf
      - antiword

terminator:
  pkg:
    - installed

other-terminal:
  pkg.installed:
    - pkgs:
      - lxterminal

{% if grains['os'] == 'Ubuntu' %}
  {% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("alacritty_ppa", "mmstick76/alacritty", require_in= "pkg: alacritty") }}

alacritty:
  pkg:
    - installed

{% endif %}
