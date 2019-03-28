include:
  - python

{% macro pip_install(package_or_packagelist, version="", require="") %}
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
      - sls: python
  {%- if require is iterable and require is not string %}
    {%- for value in require %}
      - {{ value }}
    {%- endfor %}
  {%- else %}
    {%- if require != '' %}
      - {{ require }}
    {%- endif %}
  {%- endif %}
{% endmacro %}

{% macro pip3_install(package_or_packagelist, require="") %}
{{ pip_install(package_or_packagelist, '3', require=require) }}
{% endmacro %}

{% macro pip2_install(package_or_packagelist, require="") %}
{{ pip_install(package_or_packagelist, '2', require=require) }}
{% endmacro %}
