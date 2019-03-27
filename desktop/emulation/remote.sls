
# vnc , rdp, ssh
remmina:
  pkg.installed:
    - pkgs:
      - remmina
      - remmina-plugin-vnc
      - remmina-plugin-rdp
{%- if grains['osmajorrelease']|int < 18 %}
      - remmina-plugin-gnome
{%- else %}
      - remmina-plugin-secret
      - remmina-plugin-spice
{%- endif %}