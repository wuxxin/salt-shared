{% from "lxd/defaults.jinja" import settings with context %}

{# LXD is available in backports before bionic, default on bionic, and as snap after bionic #}

{# modify kernel for production http://lxd.readthedocs.io/en/latest/production-setup/ #}
include:
  - kernel.server
{% if grains['osrelease_info'][0]|int < 18 %}
  - ubuntu.backports
{% endif %}

{#
Domain Type  Item    Value     Default Description
*      soft  memlock unlimited unset   maximum locked-in-memory address space (KB)
*      hard  memlock unlimited unset   maximum locked-in-memory address space (KB)
#}
/etc/security/limits.d/memlock.conf:
  file.managed:
    - contents: |
        *         soft    memlock   unlimited
        *         hard    memlock   unlimited

{%- if salt['grains.get']('virtual', 'unknown') != 'LXC' %}
{# This denies container access to the messages in the kernel ring buffer. Please note that this also will deny access to non-root users on the host system. #}
kernel.dmesg_restrict:
  sysctl.present:
    - value: 1 {# 0 #}
    - require_in:
      - pkg: lxd_prerequisites

{# This is the maximum number of keys a non-root user can use, should be higher than the number of containers #}
kernel.keys.maxkeys:
  sysctl.present:
    - value: 2000 {# 200 #}
    - require_in:
      - pkg: lxd_prerequisites
{%- endif %}

lxd_prerequisites:
  pkg.installed:
    - pkgs:
      - thin-provisioning-tools
      - bridge-utils
      - ebtables
    - require:
      - file: /etc/security/limits.d/memlock.conf
      - sls: kernel.server

lxd:
  file.managed:
    - name: /etc/lxd.yaml
    - contents: |
{%- for section in ['config', 'storage_pools', 'networks', 'profiles', 'projects', 'images', 'certificates'] %}
{%- if settings[section]|d(false) %}
        {{ section }}:
{{ settings[section]|yaml(false)|indent(10,True) }}
{% endif %}
{% endfor %}
  pkg.installed:
    - pkgs:
      - lxd
      - lxd-client
      - lxd-tools
      - lxc-utils
    - require:
      - pkg: lxd_prerequisites
{% if grains['osrelease_info'][0]|int < 18 %}
      - sls: ubuntu.backports
    - fromrepo: {{ grains['lsb_distrib_codename'] }}-backports
{% endif %}
{% if grains['osrelease_info'][0]|int < 18 or grains['osrelease'] == '18.04' %}
  service.running:
    - enable: True
    - require:
      - pkg: lxd
  cmd.run:
    - name: lxd init --preseed < /etc/lxd.yaml
    - onchanges:
      - file: lxd
    - require:
      - service: lxd
{% else %}
  cmd.run:
    - name: lxd init --preseed < /etc/lxd.yaml
    - onchanges:
      - file: lxd
    - require:
      - pkg: lxd
{% endif %}
