{% if grains['os'] == 'Ubuntu' %}
include:
  - kernel.nfs.common
{% endif %}

nfs_nop:
  test:
    - nop
