{% set def_user= salt['cmd.run_stdout']('getent passwd 1000 | sed -re "s/([^:]+):.*/\\1/g"', python_shell=True) %}
{% set user= salt['pillar.get']('desktop:user', def_user) %}
{% set user_info= salt['user.info'](user) %}
{% set user_home= user_info['home'] %}

{% macro add_to_groups(user, groups) %}
{{ user }}-add-to-groups:
  user.present:
    - name: {{ user }}
    - groups: {{ groups }}
    - remove_groups: False
{% endmacro %}

{% macro user_desktop(user, desktop) %}
  {% set home= salt['user.info'](user)['home'] %}

{{ desktop.Name }}.desktop:
  file.managed:
    - name: {{ home }}/.local/share/applications/{{ desktop.Name }}.desktop
    - user: {{ user }}
    - group: {{ user }}
    - contents: |
        # https://specifications.freedesktop.org/desktop-entry-spec/latest/
        [Desktop Entry]
        {%- for k,v in desktop.items() %}
        {{ k }}={{ v }}
        {%- endfor %}
  {%- if 'require' in kwargs %}
    - require:
    {%- set data = kwargs['require'] %}
    {%- if data is sequence and data is not string %}
      {%- for value in data %}
      - {{ value }}
      {%- endfor %}
    {%- else %}
      - {{ data }}
    {%- endif %}
  {%- endif %}
{% endmacro %}
