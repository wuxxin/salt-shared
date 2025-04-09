{% macro pip_install(package_or_package_list) %}
  {% import_yaml "code/python/defaults.yml" as defaults %}
  {% set settings=salt['grains.filter_by']({'default': defaults}, grain='default', 
    default= 'default', merge= salt['pillar.get']('python', {})) %}
"python{{ '3' if grains['os'] == 'Ubuntu' }}-{{ package_or_package_list }}":
  pip.installed:
  {%- if package_or_package_list is iterable and package_or_package_list is not string %}
    - pkgs: {{ package_or_package_list }}
  {%- else %}
    - name: {{ package_or_package_list }}
  {%- endif %}
  {% if 'upgrade' in kwargs %}
    - upgrade: {{ kwargs['upgrade'] }}
  {% elif settings['pip']['update']['automatic'] %}
    - upgrade: true
  {% endif %}
  {%- if 'bin_env' in kwargs %}
    - bin_env: {{ kwargs['bin_env'] }}
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


{% macro pipx_install(package, user) %} {# pipx_suffix pipx_opts, pip_args #}
  {% import_yaml "code/python/defaults.yml" as defaults %}
  {% set settings=salt['grains.filter_by']({'default': defaults}, grain='default', 
    default= 'default', merge= salt['pillar.get']('python', {})) %}
  {% set upgrade= ('upgrade' in kwargs and kwargs['upgrade']) or settings['pipx']['update']['automatic'] %}
  {% set pipx_opts= '' if 'pipx_opts' not in kwargs else kwargs['pipx_opts'] %}
  {% set pip_args= '' if 'pip_args' not in kwargs else '--pip-args=' ~ kwargs['pip_args'] %}
  {% set suffix= '' %}
  {% if 'pipx_suffix' in kwargs %}
    {% set suffix= kwargs['pipx_suffix'] %}
    {% set pipx_opts= '--suffix '~ suffix~ ' '~ pipx_opts %}
  {% endif %}
  {% set json2yaml= 'python3 -c "import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)"' %}
  {% set yamlget= 'python3 -c "import sys, yaml, functools; yaml.safe_dump(functools.reduce(dict.__getitem__, sys.argv[1:], yaml.safe_load(sys.stdin)), sys.stdout, default_flow_style=False)"' %}
  {% set package_name= package|regex_replace('\[[^\]]+\]', '') %}

"pipx_{{ package }}{{ suffix }}_{{ user }}":
  cmd.run:
    - name: pipx install {{ pipx_opts }} {{ pip_args }} {{ package }}
    - unless: pipx list --json | {{ json2yaml }} | {{ yamlget }} venvs {{ package_name }}{{ suffix }}
    - runas: {{ user }}
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

  {%- if upgrade %}
"pipx_upgrade_{{ package }}{{ suffix }}_{{ user }}":
    - name: pipx upgrade --upgrade-injected {{ package_name }}{{ suffix }}
    - runas: {{ user }}
    - require:
      - cmd: "pipx_{{ package }}{{ suffix }}_{{ user }}"
  {%- endif %}
{% endmacro %}


{% macro pipx_inject(package, package_list, user) %} {# pipx_opts, pip_args #}
  {% set inject_hash= package_list|join(' ')| md5 %}
  {% set pipx_opts= '' if 'pipx_opts' not in kwargs else kwargs['pipx_opts'] %}
  {% set pip_args= '' if 'pip_args' not in kwargs else '--pip-args=' ~ kwargs['pip_args'] %}
  {% set json2yaml= 'python3 -c "import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)"' %}
  {% set yamlget= 'python3 -c "import sys, yaml, functools; yaml.safe_dump(functools.reduce(dict.__getitem__, sys.argv[1:], yaml.safe_load(sys.stdin)), sys.stdout, default_flow_style=False)"' %}
  {% set package_name= package|regex_replace('\[[^\]]+\]', '') %}

"pipx_inject_{{ package }}_{{ user }}_{{ inject_hash }}":
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
      - pkg: python
      - cmd: "pipx_{{ package }}_{{ user }}"
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
