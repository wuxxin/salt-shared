{% from "kernel/defaults.jinja" import settings with context %}

{% if grains['virtual'] != 'LXC' %}

/etc/modprobe.d/overlay.conf:
  file.managed:
    - contents: |
  {%- for item, value in settings.overlay.items() %}
        options overlay {{ item }}={{ value }}
  {%- endfor %}

  {% for i in ['overlay', 'shiftfs'] %}
/etc/modules-load.d/{{ i }}.conf:
  file.managed:
    - contents: |
        {{ i }}

load-{{ i }}-kernel-module:
  kmod.present:
    - name: {{ i }}
    - require:
      - file: /etc/modprobe.d/{{ i }}.conf
  {% endfor %}

{% endif %}
