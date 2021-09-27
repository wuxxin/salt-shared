clevis:
  pkg.installed:
    - pkgs:
      - clevis
      - clevis-dracut

{% for i in ['clevis-clear-reboot-slot.sh', 'clevis-set-reboot-slot.sh'] %}
/usr/local/sbin/{{ i }}:
  file.managed:
    - source: salt://clevis/{{ i }}
    - mode: 755
{% endfor %}
