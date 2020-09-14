{% from "kernel/defaults.jinja" import settings with context %}

{% if grains['virtual']|lower() not in ['lxc', 'systemd-nspawn'] %}

/etc/modprobe.d/overlay.conf:
  file.managed:
    - contents: |
  {%- for item, value in settings.overlay.items() %}
        options overlay {{ item }}={{ value }}
  {%- endfor %}
    - require_in:
      - kmod: load-overlay-kernel-module

  {% for i in ['overlay', 'shiftfs'] %}
/etc/modules-load.d/{{ i }}.conf:
  file.managed:
    - contents: |
        {{ i }}

load-{{ i }}-kernel-module:
  kmod.present:
    - name: {{ i }}
  {% endfor %}

{% endif %}
