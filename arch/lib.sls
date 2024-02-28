{% macro pacman_repo_key(name, keyid, hash, owner="", user="") %}
import-repo-key-{{ name }}:
  file.managed:
    - source: "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x{{ keyid }}"
    - source_hash: {{ hash }}
    - name: /etc/pacman.d/{{ name }}-key.gpg
  cmd.run:
    - name: pacman-key --add /etc/pacman.d/{{ name }}-key.gpg
    - onchange:
      - file: import-repo-key-{{ name }}

trust-repo-key-{{ name }}:
  cmd.run:
    - name: pacman-key --lsign-key "{{ keyid }}"
    - onchange:
      - cmd: import-repo-key-{{ name }}

  {% if user != "" %}
user-trust-repo-key-{{ name }}:
  cmd.run:
    - name: gpg --import /etc/pacman.d/{{ name }}-key.gpg
    - runas: {{ user }}
    - onchange:
      - cmd: import-repo-key-{{ name }}
    - require_in:
      - test: trusted-repo-{{ name }}
  {% endif %}

trusted-repo-{{ name }}:
  test.nop:
    - require:
      - cmd: trust-repo-key-{{ name }}
{% endmacro %}


{% macro aur_install(name, pkgs=[], user="") %} {# require #}

"{{ name }}":
  cmd.run:
    - name: pamac install --no-confirm --no-upgrade {{ pkgs|join(' ') }}
    - unless: |
        test "$(comm -13 \
          <(pamac list -i -q | sort) \
          <(echo "{{ pkgs|join(' ') }}" | tr " " "\n"| sort)
        )" = ""
  {%- if 'require' in kwargs %}
    - require:
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
  test.nop:
    - require:
      - cmd: {{ name }}

{% endmacro %}


{% macro pamac_patch_install(name, patches=[], require="", user="") %}

clone-{{ name }}:
  cmd.run:
  {% if 'custom' in kwargs and kwargs['custom'] %}
    - name: 'true'
  {% else %}
    - name: pamac clone {{ name }}
    - unless: pamac list -i -q | grep -q {{ name }}
  {% endif %}
  {%- if (require is string and require != '') or
         (require is sequence and require|length > 0) %}
    - require:
    {%- if require is sequence and require is not string %}
      {%- for l in require %}
      - {{ l }}
      {%- endfor %}
    {%- else %}
      - {{ require }}
    {%- endif %}
  {%- endif %}

  {% for i in patches %}
/var/cache/pamac/{{ name }}/{{ i.name }}:
  file.managed:
    - source: {{ i.source }}
    - user: {{ salt['file.get_user']('/var/cache/pamac')}}
    - group: {{ salt['file.get_group']('/var/cache/pamac')}}
    - makedirs: true
    - onchanges:
      - cmd: clone-{{ name }}
  {% endfor %}
build-{{ name }}:
  cmd.run:
    - name: pamac build --no-clone --no-confirm {{ name }}
    - onchanges:
  {% for i in patches %}
      - file: /var/cache/pamac/{{ name }}/{{ i.name }}
  {% endfor %}
    - require:
  {% for i in patches %}
      - file: /var/cache/pamac/{{ name }}/{{ i.name }}
  {% endfor %}
{{ name }}:
  test.nop:
    - require:
      - cmd: build-{{ name }}

{% endmacro %}


{% macro pamac_patch_install_dir(name, srcdir) %} {# require, custom #}

{%- set d = kwargs['require']|d([]) %}
{%- set c = kwargs['custom']|d(false) %}

{{ pamac_patch_install(name,
  [{'name': '.SRCINFO', 'source': srcdir ~'/.SRCINFO'},
   {'name': 'PKGBUILD', 'source': srcdir ~'/PKGBUILD'},
  ], require= d, custom= c) }}
{% endmacro %}
