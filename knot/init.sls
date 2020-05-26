{% from "knot/defaults.jinja" import settings with context %}
{% from "knot/defaults.jinja" import defaults, log_default, template_default %}
{% from "knot/lib.sls" import write_zone, write_config %}

{% from "ubuntu/init.sls" import apt_add_repository %}

{# knot from ppa is newer for almost any distro #}
{{ apt_add_repository("knot_ppa", "cz.nic-labs/knot-dns-latest",
  require_in = "pkg: knot-package") }}

knot-package:
  pkg.installed:
    - names:
      - knot
      - knot-dnsutils
      - knot-doc
      - knot-host

knot-config-check:
  file.managed:
    - name: /usr/local/sbin/knot-config-check
    - contents: |
        #!/bin/sh
        /usr/sbin/knotc -c $1 conf-check
        exit $?
    - mode: "0755"
    - require:
      - pkg: knot-package


{% if settings.enabled|d(true) %}

{{ write_config('', settings, log_default, template_default) }}
  {%- for zone in settings.zone %}
    {%- set targetpath= settings.template|selectattr('id', 'equalto',
        zone.template|d('default'))|map(attribute='storage')|first %}
{{ write_zone(zone, settings.common, targetpath, watch_in="knot.service") }}
  {%- endfor %}

knot.service:
  service.running:
    - enable: true
    - require:
      - pkg: knot-package
    - watch:
      - file: /etc/default/knot
      - file: /etc/knot/knot.conf

{%- else %}
knot.service:
  service.dead:
    - disable: true

{%- endif %}


{% if settings.profile|d(false) %}
  {% for instance in settings.profile %}

    {% set name = instance.name %}
    {% set profile_defaults = defaults %}
    {% do profile_defaults.server.update({'rundir': ''}) %}
    {% do profile_defaults.database.update({'storage': ''}) %}
    {% set profile_template= template_default %}
    {% do profile_template.update({'storage': ''}) %}
    {% set merged_config=salt['grains.filter_by']({'none': profile_defaults},
      grain='none', default= 'none', merge= instance) %}

    {% if merged_config.enabled|d(true) %}

{{ write_config(name, merged_config, log_default, profile_template) }}
      {%- for zone in merged_config.zone %}
        {%- set targetpath=  merged_config.template|selectattr('id', 'equalto',
            zone.template|d('default'))|map(attribute='storage')|first %}
{{ write_zone(zone, merged_config.common, targetpath, watch_in="knot-{{ name }}.service") }}
      {%- endfor %}

knot-{{ name }}.service:
  service.running:
    - enable: true
    - require:
      - pkg: knot-package
    - watch:
      - file: /etc/default/knot-{{ name }}
      - file: /etc/knot/knot{{ name }}.conf

    {%- else %}
knot-{{ name }}.service:
  service.dead:
    - disable: true

    {%- endif %}
  {% endfor %}
{% endif %}
