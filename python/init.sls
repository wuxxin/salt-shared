python:
  pkg.installed:
    - pkgs:
      - python
      - python2.7
      - python-setuptools
      - python-pip
      - python-pip-whl
      - python3
      - python3-pip
      - python3-setuptools

{# XXX pip and virtualenv is broken on xenial, update from pypi #}
{# https://github.com/pypa/pip/issues/3282 #}

pip2-upgrade:
  cmd.run:
    - name:  easy_install -U pip virtualenv
    - onlyif: test "$(which pip2)" = "/usr/bin/pip2"

pip3-upgrade:
  cmd.run:
    - name: easy_install3 -U pip virtualenv
    - onlyif: test "$(which pip3)" = "/usr/bin/pip3"


{% macro pip_install(package_or_packagelist, version="") %}
python{{ version }}-{{ package_or_packagelist }}:
  pip.installed:
  {%- if package_or_packagelist is iterable and package_or_packagelist is not string %}
    - pkgs: {{ package_or_packagelist}}
  {%- else %}
    - name: {{ package_or_packagelist }}
  {%- endif %}
  {%- if version %}
    - bin_env: {{ '/usr/local/bin/pip'+ version }}
  {%- endif %}
    - require:
      - pkg: python
      - cmd: pip2-upgrade
      - cmd: pip3-upgrade
  {%- if kwargs is defined %}
    {%- for k,d in kwargs.iteritems() %}
    - {{ k }}: {{ d }}
    {%- endfor %}
  {%- endif %}
{% endmacro %}

{% macro pip3_install(package_or_packagelist) %}
{{ pip_install(package_or_packagelist, '3') }}
{% endmacro %}

{% macro pip2_install(package_or_packagelist) %}
{{ pip_install(package_or_packagelist, '2') }}
{% endmacro %}
