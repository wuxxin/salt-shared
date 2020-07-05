{% from "email/defaults.jinja" import settings with context %}

getmail:
  pkg:
    - installed

app-getmail@.service:
  file.managed:
    - name: /etc/systemd/system/app-getmail@.service
    - source: salt://email/app-getmail@.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - onchanges_in:
      - cmd: systemd_reload
    - require:
      - pkg: getmail

"{{ settings.etc_dir }}/getmail":
  file.directory:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - dir_mode: 770
    - file_mode: 660
    - makedirs: true

{% for entry in salt['pillar.get']('email:incoming:getmail', []) %}
  {% if entry.name|d(False) != False and entry.config|d(False) != False %}
"{{ settings.etc_dir }}/getmail/{{ entry.name }}":
  file.managed:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - mode: 660
    - contents: |
{{ entry.config |indent(8,True) }}

app-getmail@{{ entry.name }}.service:
  service:
    {%- if entry.enabled|d(True) %}
    - enabled
    {%- else %}
    - disabled
    {%- endif %}
    - require:
      - file: app-getmail@.service
  {% endif %}
{% endfor %}
