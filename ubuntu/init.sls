
{% macro apt_add_repository(statename, ppaname) %}

{{ statename }}:
  pkg.installed:
    - pkgs:
      - software-properties-common
      - update-notifier-common
{%- if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 '+
  '"http://ppa.launchpad.net/'+ ppaname+ '/ubuntu/dists/'+
  grains['oscodename']+ '/InRelease" | grep -qE "^HTTP/[12]\.?1? 200"', python_shell=true) == 0 %}
  pkgrepo.managed:
    - ppa: {{ ppaname }}
    - file: /etc/apt/sources.list.d/{{ statename }}.list
    - dist: {{ grains['oscodename'] }}
    - require:
      - pkg: {{ statename }}
  {%- if kwargs['require_in']|d(None) %}
    - require_in:
    {%- if kwargs['require_in'] is string %}
      - {{ kwargs['require_in'] }}
    {%- else %}
      {%- for i in kwargs['require_in'] %}
      - {{ i }}
      {%- endfor %}
    {%- endif %}
  {%- endif %}
{%- endif %}

{% endmacro %}
