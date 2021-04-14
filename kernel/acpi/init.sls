acpid:
  pkg.installed:
    - pkgs:
      - acpid
      - acpi
  service.running:
    - name: acpid
    - enable: true
    - require:
      - pkg: acpid
