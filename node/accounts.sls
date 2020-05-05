{% from "node/defaults.jinja" import settings %}
{% from "ssh/lib.sls" import ssh_keys_update %}

include:
  - .hostname

{%- for u in settings.user|d([]) %}
user_present_{{ u.name }}:
  user.present:
    - name: {{ u.name }}
  {%- for name,value in u.items() %}
    {%- if name != 'name' %}
      {{ name }}: {{ value }}
    {%- endif %}
  {%- endfor %}
{%- endfor %}

{%- for u in settings.group|d([]) %}
group_present_{{ u.name }}:
  group.present:
    - name: {{ u.name }}
  {%- for name,value in u.items() %}
    {%- if name != 'name' %}
      {{ name }}: {{ value }}
    {%- endif %}
  {%- endfor %}
{%- endfor %}

{% for n in settings.ssh_user|d([]) %}
{{ ssh_keys_update(n,
    salt['pillar.get']('ssh_authorized_keys', False),
    salt['pillar.get']('ssh_deprecated_keys', False)
    )
}}
{% endfor %}
