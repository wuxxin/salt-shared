include:
  - python

{% macro pip_install(package_or_packagelist, version="3", kwargs={}) %}
  {% from "python/defaults.jinja" import settings as python_settings with context %}
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


{% macro pipx_install(package, user) %}
  {% from "python/defaults.jinja" import settings as python_settings with context %}
  {% set upgrade= ('upgrade' in kwargs and kwargs['upgrade']) or
      python_settings['pipx']['update']['automatic'] %}
  {% set pipx_opts= '' if 'pipx_opts' not in kwargs else kwargs['pipx_opts'] %}

pipx_{{ package }}:
  cmd.run:
    - name: pipx install {{ pipx_opts }} {{ package }}
    - unless: pipx list | grep package {{ package }} -q
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

  {%- if upgrade %}
pipx_upgrade_{{ package }}:
    - name: pipx upgrade --upgrade-injected {{ package }}
    - runas: {{ user }}
    - require:
      - cmd: pipx_{{ package }}
  {%- endif %}
{% endmacro %}


{% macro pipx_inject(package, packagelist, user) %}
  {% set inject_hash= packagelist|join(' ')| md5 %}
  {% set pipx_opts= '' if 'pipx_opts' not in kwargs else kwargs['pipx_opts'] %}

pipx_inject_{{ package }}_{{ inject_hash }}:
  cmd.run:
    - name: pipx inject {{ pipx_opts }} {{ package }} {{ packagelist|join(' ') }}
    - runas: {{ user }}
    # FIXME make unless for injected packages working
    # - unless: |
    #     pipx list | grep package {{ package }} -q &&
    #     pipx list --include-injected |
    - require:
      - cmd: pipx_{{ package }}
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
    {%- if k != 'require' %}
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

{% macro pip3_install(package_or_packagelist) %}
{{ pip_install(package_or_packagelist, '3', kwargs=kwargs) }}
{% endmacro %}

{% macro pip2_install(package_or_packagelist) %}
{{ pip_install(package_or_packagelist, '2', kwargs=kwargs) }}
{% endmacro %}
