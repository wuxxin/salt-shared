{% from "node/defaults.jinja" import settings %}
{% from "server/ssh/lib.sls" import ssh_keys_update %}

include:
  - .hostname


{% if settings.users %}
  {% for u in settings.users %}
user_present_{{ u.name }}:
  test.show_notification:
    - text: |
        WARNING: FIXME: user_present_{{ u.name }} currently disabled, because "linux_shadow.py, line 74: getspnam = functools.partial(spwd.getspnam)" needs to be patched
{#
  user.present:
    - name: {{ u.name }}
    - remove_groups: false
    {%- for name,value in u.items() %}
      {%- if name != 'name' and name != 'use_authorized_keys' %}
      {{ name }}: {{ value }}
      {%- endif %}
    {%- endfor %}
#}
    {%- if u.use_authorized_keys|d(False) %}
{{ ssh_keys_update(u.name,
  salt['pillar.get']('ssh_authorized_keys', False),
  salt['pillar.get']('ssh_deprecated_keys', False)
  )
}}
    {%- endif %}
  {% endfor %}
{% endif %}

{% if settings.groups %}
  {% for u in settings.groups %}
group_present_{{ u.name }}:
  test.show_notification:
    - text: |
        WARNING: FIXME: group_present_{{ u.name }} currently disabled, because "linux_shadow.py, line 74: getspnam = functools.partial(spwd.getspnam)" needs to be patched
{#
  group.present:
    - name: {{ u.name }}
    {%- for name,value in u.items() %}
      {%- if name != 'name' %}
      {{ name }}: {{ value }}
      {%- endif %}
    {%- endfor %}
#}
  {% endfor %}
{% endif %}

