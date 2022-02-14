filesystem-tools:
  pkg.installed:
    - pkgs:
      - mdadm
      - lvm2
      - thin-provisioning-tools

storage-tools:
  pkg.installed:
    - pkgs:
      - smartmontools
      - nvme-cli
      - hdparm

{% if grains['os_family'] in ["Debian", "Arch"] %}
temperature-tools:
  pkg.installed:
    - pkgs:
  {% if grains['os_family'] == "Debian" %}
      - lm-sensors
  {% elif grains['os_family'] == "Arch" %}
      - lm_sensors
  {% endif %}
{% endif %}
