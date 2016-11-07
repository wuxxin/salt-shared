python:
  pkg.installed:
    - pkgs:
      - python
      - python2.7
      - python3
{% if grains['lsb_distrib_codename'] not in ['trusty', 'xenial'] %}
      - python-pip
      - python-virtualenv
{% else %}

{# refresh old "faulty" pip with version from pypi, as workaround for saltstack and probably others #}

remove_faulty_pip:
  pkg.removed:
    - pkgs:
      - python-pip
      - python-pip-whl
    - require:
      - pkg: python

  {% for i in ['', '3'] %}

easy_install{{ i }}_pip:
  cmd.run:
    - name: easy_install{{ i }} pip
    - unless: which pip{{ i }}
    - require:
      - pkg: remove_faulty_pip
{#  - reload_modules: true #}

  {% endfor %}

{% endif %}

pudb:
  pip.installed:
    - require:
      - pkg: python
{% if grains['lsb_distrib_codename'] in ['trusty', 'xenial'] %}
      - cmd: easy_install_pip
{% endif %}
