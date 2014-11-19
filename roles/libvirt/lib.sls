
{% macro set_autostart(hostname, autostart='on') %}
set_autostart_vm:
  module.run:
    - name: virt.set_autostart
    - vm: {{ hostname }}
    - state: {{ autostart }}
{% endmacro %}


{% macro start_vm(hostname) %}

start_backup_vm:
  module.run:
    - name: virt.start
    - m_name: {{ hostname }}

{% endmacro %}
