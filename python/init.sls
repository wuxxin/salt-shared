python:
  pkg.installed:
    - pkgs:
      - python
{% if grains['lsb_distrib_codename'] not in ['Mint', 'trusty'] %}
      - python-pip
      - python-virtualenv
{% else %}
      - python-virtualenv

remove_faulty_pip:
  pkg.removed:
    - pkgs:
      - python-pip
      - python-pip-whl
    - require:
      - pkg: python

easy_install_pip:
  cmd.run:
    - name: easy_install pip
    - unless: which pip
    - require:
      - pkg: remove_faulty_pip

{% endif %}

pudb:
  pip.installed:
    - require:
      - pkg: python
{% if grains['lsb_distrib_codename'] not in ['Mint', 'trusty'] %}
      - cmd: easy_install_pip
{% endif %}
