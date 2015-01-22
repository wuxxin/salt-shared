{% from "roles/salt/defaults.jinja" import settings as s with context %}

{{ s.master.extensions.base }}:
  file.directory:
    - makedirs: True

{% for f, d in s.master.extensions.iteritems() %}
{% if f != 'base' and f != 'status' %}
{{ s.master.extensions.base }}/{{ f }}:
  file.symlink:
    - target: {{ d }}
    - require:
      - file: {{ s.master.extensions.base }}
    - require_in:
      - file: /etc/salt/master.d/extensions.conf
{% endif %}
{% endfor %}

/etc/salt/master.d/extensions.conf:
  file.managed:
    - contents: 
        extension_modules: {{ s.master.extensions.base }}
    - watch_in:
      - service: salt-master

