{% if grains['virtual']|lower() not in ['lxc', 'systemd-nspawn'] %}

  {% for i in ['overlay',] %}
/etc/modules-load.d/{{ i }}.conf:
  file.managed:
    - contents: |
        {{ i }}

load-{{ i }}-kernel-module:
  kmod.present:
    - name: {{ i }}
  {% endfor %}

{% endif %}
