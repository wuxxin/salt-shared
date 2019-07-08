include:
  - python

{% macro pip_install(package_or_packagelist, version="3", kwargs={}) %}
"python{{ version }}-{{ package_or_packagelist }}":
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
      - cmd: pip3-upgrade
  {%- if kwargs is defined %}
    {%- for k,d in kwargs.items() %}
    - {{ k }}: {{ d }}
    {%- endfor %}
  {%- endif %}
{% endmacro %}

{% macro pip3_install(package_or_packagelist) %}
{{ pip_install(package_or_packagelist, '3', kwargs=kwargs) }}
{% endmacro %}

{% macro pip2_install(package_or_packagelist) %}
{{ pip_install(package_or_packagelist, '2', kwargs=kwargs) }}
{% endmacro %}
