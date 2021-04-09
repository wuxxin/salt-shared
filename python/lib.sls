include:
  - python

{% macro pip_install(package_or_packagelist, version="3", kwargs={}) %}
  {% from "python/defaults.jinja" import settings as python_settings %}
"python{{ version }}-{{ package_or_packagelist }}":
  pip.installed:
  {%- if package_or_packagelist is iterable and package_or_packagelist is not string %}
    - pkgs: {{ package_or_packagelist }}
  {%- else %}
    - name: {{ package_or_packagelist }}
  {%- endif %}
  {% if 'upgrade' in kwargs %}
    - upgrade: {{ kwargs['upgrade'] }}
  {% elif python_settings['packages']['update']['automatic'] %}
    - upgrade: true
  {% endif %}
  {%- if version %}
    - bin_env: {{ '/usr/local/bin/pip'+ version }}
  {%- endif %}
    - require:
      - pkg: python
      - cmd: pip3-upgrade
  {%- if 'require' in kwargs %}
    {%- set d = kwargs['require'] %}
    {%- if d is sequence and d is not string %}
      {%- for l in d %}
      - {{ l }}
      {%- endfor %}
    {%- else %}
      - {{ d }}
    {%- endif %}
  {%- endif %}
  {%- for k,d in kwargs.items() %}
    {%- if k != 'require' and k != 'upgrade' %}
      {%- if d is sequence and d is not string %}
    - {{ k }}:
        {%- for l in d %}
      - {{ l }}
        {%- endfor %}
      {%- else %}
    - {{ k }}: {{ d }}
      {%- endif %}
    {%- endif %}
  {%- endfor %}
{% endmacro %}


{% macro pix_install(package, user, kwargs={}) %}
  {% from "python/defaults.jinja" import settings as python_settings %}
  {% set upgrade= ('upgrade' in kwargs and kwargs['upgrade']) or
      python_settings['pipx']['update']['automatic'] %}
pipx_{{ package }}:
  cmd.run:
    - name: pipx install {{ '-U' if upgrade }}{{ package }}
    - unless: pipx list | grep {{ package }} -q
    - runas: {{ user }}
    - require:
      - pip: pipx
  {%- if 'require' in kwargs %}
    {%- set d = kwargs['require'] %}
    {%- if d is sequence and d is not string %}
      {%- for l in d %}
      - {{ l }}
      {%- endfor %}
    {%- else %}
      - {{ d }}
    {%- endif %}
  {%- endif %}
  {%- for k,d in kwargs.items() %}
    {%- if k != 'require' and k != 'upgrade' %}
      {%- if d is sequence and d is not string %}
    - {{ k }}:
        {%- for l in d %}
      - {{ l }}
        {%- endfor %}
      {%- else %}
    - {{ k }}: {{ d }}
      {%- endif %}
    {%- endif %}
  {%- endfor %}
{% endmacro %}

{% macro pix_inject(package, package_or_packagelist, user, kwargs={}) %}
pipx_inject_{{ package }}_{{ hash(package_or_packagelist) }}:
  cmd.run:
    - name: pipx install {{ '-U' if upgrade }}{{ package }}
    - unless: |
        pipx list | grep {{ package }} -q &&
        pipx list |
    - runas: {{ user }}
    - require:
      - pip: pipx
--include-apps

{% endmacro %}

{% macro pip3_install(package_or_packagelist) %}
{{ pip_install(package_or_packagelist, '3', kwargs=kwargs) }}
{% endmacro %}

{% macro pip2_install(package_or_packagelist) %}
{{ pip_install(package_or_packagelist, '2', kwargs=kwargs) }}
{% endmacro %}
