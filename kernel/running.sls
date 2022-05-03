{% if grains['os'] == 'Ubuntu' %}

linux-tools:
  pkg.installed:
    - pkgs:
      - linux-tools-{{ grains['kernelrelease'] }}

linux-headers:
  pkg.installed:
    - pkgs:
      - linux-headers-{{ grains['kernelrelease'] }}
{% else %}

linux-tools:
  test:
    - nop

linux-headers:
  test:
    - nop
    
{% endif %}
