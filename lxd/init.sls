include:
  - kernel
  - cgroup
  - lxd.ppa
{% if grains['osname'] == 'trusty' %}
  {# lxd needs newer (2.0.x) libxc1, trusty has it in backports #}
  - ubuntu.backports
{% endif %}

lxd:
  pkg.installed:
    - pkgs:
      - lxc
      - lxd
      - lxd-tools
      - bridge-utils
    - require:
      - sls: cgroup
      - sls: lxd.ppa
{% if grains['osname'] == 'trusty' %}
      - sls: ubuntu.backports
{% endif %}
