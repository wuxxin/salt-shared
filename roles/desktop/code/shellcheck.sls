{% if grains['lsb_distrib_codename'] == 'trusty' %}

include:
  - repo.ubuntu

trusty-backports:
  pkgrepo.managed:
    - repo: 'deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse'
    - file: /etc/apt/sources.list.d/trusty-backports.list

shellcheck:
  pkg.installed:
    - require:
      - pkgrepo: trusty-backports

{% else %}

shellcheck:
  pkg:
    - installed

{% endif %}
