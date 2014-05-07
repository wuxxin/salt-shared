acpid:
  pkg:
    - installed
  service:
    - running
    - require:
      - pkg: acpid

{% if grains['os'] == 'Debian' %}

/etc/acpi/events:
  file.directory:
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - require:
      - pkg: acpid
    - watch_in: 
      - service: acpid

/etc/acpi/events/powerbtn:
  file.managed:
    - source: salt://acpi/powerbtn
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - require_in:
      - service: acpid

/etc/acpi/powerbtn.sh:
  file.managed:
    - source: salt://acpi/powerbtn.sh
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require_in:
      - service: acpid

{% endif %}
