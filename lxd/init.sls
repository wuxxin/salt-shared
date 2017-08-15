include:
  - kernel
  - cgroup
  - lxd.ppa
{% if grains['osname'] == 'trusty' %}
  {# need newer (2.0.x) version of libxc1 in trusty backports #}
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
