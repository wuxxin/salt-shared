{% if grains['lsb_distrib_codename'] == 'trusty' %}

include:
  - ubuntu
  - ubuntu.backports

shellcheck:
  pkg.installed:
    - fromrepo: {{ grains['lsb_distrib_codename'] }}-backports
    - require:
      - sls: ubuntu.backports
    
{% else %}

shellcheck:
  pkg:
    - installed

{% endif %}
