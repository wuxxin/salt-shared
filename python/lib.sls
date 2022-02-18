{% macro pip_install(package_or_package_list, version="") %}
  {% from "python/defaults.jinja" import settings as python_settings with context %}
"python{{ version }}-{{ package_or_package_list }}":
  pip.installed:
  {%- if package_or_package_list is iterable and package_or_package_list is not string %}
    - pkgs: {{ package_or_package_list }}
  {%- else %}
    - name: {{ package_or_package_list }}
  {%- endif %}
  {% if 'upgrade' in kwargs %}
    - upgrade: {{ kwargs['upgrade'] }}
  {% elif python_settings['pip']['update']['automatic'] %}
    - upgrade: true
  {% endif %}
  {%- if version %}
    - bin_env: {{ '/usr/local/bin/pip'+ version }}
  {%- endif %}
    - require:
      - pkg: python
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


{% macro pip2_install(package_or_package_list) %}
{{ pip_install(package_or_package_list, '2', kwargs=kwargs) }}
{% endmacro %}


{% macro pipx_install(package, user) %} {# pipx_opts, pip_args #}
  {% from "python/defaults.jinja" import settings as python_settings with context %}
  {% set upgrade= ('upgrade' in kwargs and kwargs['upgrade']) or
      python_settings['pipx']['update']['automatic'] %}
  {% set pipx_opts= '' if 'pipx_opts' not in kwargs else kwargs['pipx_opts'] %}
  {% set pip_args= '' if 'pip_args' not in kwargs else '--pip-args ' ~ kwargs['pip_args'] %}
  {% set json2yaml= 'python3 -c "import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)"' %}
  {% set yamlget= 'python3 -c "import sys, yaml, functools; yaml.safe_dump(functools.reduce(dict.__getitem__, sys.argv[1:], yaml.safe_load(sys.stdin)), sys.stdout, default_flow_style=False)"' %}
  {% set package_name= package|regex_replace('\[[^\]]+\]', '') %}

"pipx_{{ package }}":
  cmd.run:
    - name: pipx install {{ pipx_opts }} {{ pip_args }} {{ package }}
    - unless: pipx list --json | {{ json2yaml }} | {{ yamlget }} venvs {{ package_name }}
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
"pipx_upgrade_{{ package }}":
    - name: pipx upgrade --upgrade-injected {{ package_name }}
    - runas: {{ user }}
    - require:
      - cmd: "pipx_{{ package }}"
  {%- endif %}
{% endmacro %}


{% macro pipx_inject(package, package_list, user) %} {# pipx_opts, pip_args #}
  {% set inject_hash= package_list|join(' ')| md5 %}
  {% set pipx_opts= '' if 'pipx_opts' not in kwargs else kwargs['pipx_opts'] %}
  {% set pip_args= '' if 'pip_args' not in kwargs else '--pip-args ' ~ kwargs['pip_args'] %}
  {% set json2yaml= 'python3 -c "import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)"' %}
  {% set yamlget= 'python3 -c "import sys, yaml, functools; yaml.safe_dump(functools.reduce(dict.__getitem__, sys.argv[1:], yaml.safe_load(sys.stdin)), sys.stdout, default_flow_style=False)"' %}
  {% set package_name= package|regex_replace('\[[^\]]+\]', '') %}

"pipx_inject_{{ package }}_{{ inject_hash }}":
  cmd.run:
    - name: pipx inject {{ pipx_opts }} {{ pip_args }} {{ package_name }} {{ package_list|join(' ') }}
    - runas: {{ user }}
    - unless: |
        injected=$(pipx list --include-injected --json | \
          {{ json2yaml }} | \
          {{ yamlget }} venvs {{ package_name }} metadata injected_packages | \
          grep -Ev "^ +" | sed -r "s/(.+):$/\1/g")
        for i in {{ package_list|join(' ')|regex_replace('\[[^\]]+\]', '') }}; do
          printf "%s" "${injected}" | grep -Eq "^${i}$"
        done
    - require:
      - pip: pipx
      - cmd: "pipx_{{ package }}"
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
