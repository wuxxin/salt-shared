include:
  - .ppa

ansible:
  pkg:
    - installed
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
    - require:
      - cmd: ansible_ppa
{% endif %}

librarian-ansible:
  gem:
    - installed

