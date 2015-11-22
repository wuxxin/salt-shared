python:
  pkg.installed:
    - pkgs:
      - python
{% if grains['lsb_distrib_codename'] not in ['trusty', 'rafaela', 'romeo'] %}
      - python-pip
      - python-virtualenv
{% else %}
      - python-virtualenv

{# refresh old "faulty" pip with version from pypi, as workaround for saltstack and probably others #}

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
{% if grains['lsb_distrib_codename'] in ['trusty', 'rafaela', 'romeo'] %}
      - cmd: easy_install_pip
{% endif %}
