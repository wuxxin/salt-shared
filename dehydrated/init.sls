include:
  - openssl

{% from "dehydrated/defaults.jinja" import settings, letsencrypt with context %}
        
dehydrated-user:
  group.present:
    - name: dehydrated
  user.present:
    - name: dehydrated
    - gid: dehydrated
    - home: /usr/local/etc/dehydrated
    - shell: /bin/bash
    - remove_groups: False
    - groups:
      - www-data

/usr/local/bin/dehydrated:
  file.managed:
    - source: salt://dehydrated/dehydrated
    - mode: "0775"

{% for i in ['acme-challenge', 'certs'] %}
/usr/local/etc/dehydrated/{{ i }}:
  file.directory:
    - user: dehydrated
    - group: dehydrated
    - makedirs: true
{% endfor %}

/usr/local/etc/dehydrated/hook-empty.sh:
  file.managed:
    - user: dehydrated
    - group: dehydrated
    - name: salt://dehydrated/examples/hook.sh
    - mode: "0755"

/usr/local/etc/dehydrated/config:
  file.managed:
    - user: dehydrated
    - group: dehydrated
    - contents: |
        BASEDIR="/usr/local/etc/dehydrated"
        WELLKNOWN="/usr/local/etc/dehydrated/acme-challenge"
        {%- if letsencrypt.staging|d(true) %}
        CA={{ settings.staging.ca }}
        OLDCA={{ settings.staging.oldca }}
        {%- else %}
        CA={{ settings.production.ca }}
        OLDCA={{ settings.production.oldca }}
        {%- endif %}
        CONTACT_EMAIL={{ letsencrypt.contact_email }}
        HOOK={{ letsencrypt.hook }}
        {%- set config=letsencrypt.config|d({}) %}
        {%- for i, d in config.iteritems() %}
        {{ i|upper }}="{{ d }}"
        {%- endfor %}

/usr/local/etc/dehydrated/domains.txt:
  file.managed:
    - user: dehydrated
    - group: dehydrated
    - contents: |
        {%- for entry in letsencrypt.domains %}
        {{ entry.split(' ')[0] }}{%- for sub in entry.split(' ') %} {{ sub }}{%- endfor %}
        {%- endfor %}

{% if letsencrypt.apache|d(false) %}
/etc/apache2/conf-available/10-wellknown-acme.conf:
  file.managed:
    - source: salt://dehydrated/apache.conf
    - makedirs: true

/etc/apache2/conf-enabled/10-wellknown-acme.conf:
  file.symlink:
    - target: /etc/apache2/conf-available/10-wellknown-acme.conf
    - makedirs: true
{% endif %}
{% if letsencrypt.nginx|d(false) %}
{% endif %}

