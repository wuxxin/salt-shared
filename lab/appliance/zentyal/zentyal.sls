include:
  - lab.appliance.zentyal.base

{# ### apache #}  
{# XXX activate needed apache modules early in setup, so apache is config is valid, and service is available for letsencrypt #}
/etc/apache2/mods-available/ssl.conf:
  file.managed:
    - source: salt://lab/appliance/zentyal/files/ssl.conf
    - require_in:
      - file: zentyal-apache-enable-ssl-conf
 
{% for i in ['proxy', 'proxy_http', 'headers', 'ssl'] %}
  {% for j in ['conf', 'load'] %}
zentyal-apache-enable-{{ i }}-{{ j }}:
  file.symlink:
    - name: /etc/apache2/mods-enabled/{{ i }}.{{ j }}
    - target: ../mods-available/{{ i }}.{{ j }}
    - watch_in:
      - service: zentyal-apache-restart-module-config
    - require:
      - pkg: zentyal
  {% endfor %}
{% endfor %}
    
zentyal-apache-restart-module-config:
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: zentyal

{# ### nslookup for salt via /etc/hosts #}
{# XXX workaround not resolving salt master after zentyal internal dns installation, add salt to /etc/hosts #}
{% if grains['master'] != '' %}
  {% set saltshort = grains['master'] %}
  {% for domain in salt['grains.get']('dns:search') %}
    {% set saltmaster = saltshort+ "."+ domain %}
    {% set saltip = salt['dnsutil.A'](saltmaster) %}
    {% if saltip is iterable and saltip is not string and saltip[0] != '' %}
adding-salt-master-to-hosts:
  file.replace:
    - name: /etc/hosts
    - append_if_not_found: true
    - pattern: |
        ^.*{{ saltshort }}.*{{ saltshort }}.*
  
    - repl: |
        {{ saltip[0] }} {{ saltmaster }} {{ saltshort }}
  
    {% endif %}
  {% endfor %}
{% endif %}

{# disable warning flooding logs #}
sogo-tmpreaper:
  file.replace:
    - name: /etc/tmpreaper.conf
    - pattern: |
        ^.*SHOWWARNING=.*
    - repl: |
        SHOWWARNING=false

    - append_if_not_found: true
    - backup: false
    - require:
      - pkg: zentyal


{# ### templates #}
{% for n in ['core/nginx.conf.mas', 'mail/main.cf.mas', 'mail/dovecot.conf.mas'] %}
/etc/zentyal/stubs/{{ n }}:
  file.managed:
    - source: salt://lab/appliance/zentyal/files/stubs/{{ n }}
    - require:
      - sls: lab.appliance.zentyal.base
{% endfor %}


{# ### hooks #}
{% for n in ['mail', 'samba', 'sogo'] %}
/etc/zentyal/hooks/{{ n }}.postsetconf:
  file.managed:
    - source: salt://lab/appliance/zentyal/files/hooks/{{ n }}.postsetconf
    - template: jinja
    - mode: "755"
    - require:
      - sls: lab.appliance.zentyal.base
{% endfor %}


{% if pillar.appliance.zentyal.sync|d(false) %}
{# ### imap mail migration #}
offlineimap:
  pkg:
    - installed

/home/{{ pillar.appliance.zentyal.admin.user }}/.offlineimaprc:
  file.managed:
    - source: {{ pillar.appliance.zentyal.sync.config }}
    - template: jinja
    - user: {{ pillar.appliance.zentyal.admin.user }}
    - context:
        sync_sets: {{ pillar.appliance.zentyal.sync.set }}
        functions: {{ pillar.appliance.zentyal.sync.functions}}
    - require:
      - pkg: offlineimap
      - pkg: zentyal

/home/{{ pillar.appliance.zentyal.admin.user }}/.offlineimap/{{ pillar.appliance.zentyal.sync.functions.name }}:
  file.managed:
    - source: {{ pillar.appliance.zentyal.sync.functions.name }}
    - template: jinja
    - user: {{ pillar.appliance.zentyal.admin.user }}
    - makedirs: true
    - require:
      - pkg: offlineimap
      - pkg: zentyal
      - user: zentyal-admin-user
{% endif %}
