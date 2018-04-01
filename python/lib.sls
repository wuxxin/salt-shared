include:
  - python

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
# pip3_install extra: {{ kwargs }}
{{ pip_install(package_or_packagelist, '3') }}
{% endmacro %}

{% macro pip2_install(package_or_packagelist) %}
# pip2_install extra: {{ kwargs }}
{{ pip_install(package_or_packagelist, '2') }}
{% endmacro %}
