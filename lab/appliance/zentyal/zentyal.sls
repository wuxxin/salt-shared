include:
  - lab.appliance.zentyal.base

{# ### apache #}  
{# XXX activate needed apache modules early in setup, so apache is config is valid, and service is available for letsencrypt #}
/etc/apache2/mods-available/ssl.conf:
  file.managed:
    - source: salt://lab/appliance/zentyal/files/ssl.conf
    - require_in:
      - file: zentyal-apache-enable-ssl.conf
 
{% for i in ['proxy.conf', 'proxy.load', 'proxy_http.load', 
  'socache_shmcb.load', 'ssl.conf', 'ssl.load', 'headers.load'] %}
zentyal-apache-enable-{{ i }}:
  file.symlink:
    - name: /etc/apache2/mods-enabled/{{ i }}
    - target: ../mods-available/{{ i }}
    - watch_in:
      - service: zentyal-apache-restart-module-config
    - require:
      - pkg: zentyal
{% endfor %}

zentyal-apache-restart-module-config:
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: zentyal

{# XXX disable mk_home (tries chown +1234:+1234 but "+" is unsupported) #}
/etc/zentyal/users.conf:
  file.managed:
    - contents: |
        # CUSTOMIZE-ZENTYAL-BEGIN
        # whether to create user homes or not
        mk_home = no
        # default mode for home directory (umask mode)
        dir_umask = 0077
        # enable quota support
        enable_quota = no
        # CUSTOMIZE-ZENTYAL-END

/etc/zentyal/firewall.conf:
  file.managed:
    - contents: |
        # CUSTOMIZE-ZENTYAL-BEGIN
        # Limit of logged packets per minute.
        iptables_log_limit = 50
        # Burst
        iptables_log_burst = 10
        # Logs all the drops
        iptables_log_drops = yes
        # Extra iptables modules to load
        # Each module should be sperated by a comma, you can include module parameters
        iptables_modules = 
        # Enable source NAT, if your router does NAT you can disable it
        nat_enabled = no
        # Uncomment the following to show the from External to Internal section
        #show_ext_to_int_rules = yes
        # Uncomment the following to show the Rules added by Zentyal services
        #show_service_rules = yes
        # CUSTOMIZE-ZENTYAL-END
      
{# ### hooks #}
{% for n in ['webadmin', 'mail', 'sogo'] %}
/etc/zentyal/hooks/{{ n }}.postsetconf:
  file.managed:
    - source: salt://lab/appliance/zentyal/files/hooks/{{ n }}.postsetconf
    - template: jinja
    - mode: "755"
    - makedirs: true
    
{% endfor %}

{# ### nslookup for salt via /etc/hosts #}
{# XXX workaround not resolving salt master after zentyal internal dns installation, add salt to /etc/hosts #}
{% if grains['master'] != '' %}
  {% set saltshort = grains['master'] %}
  {% if not salt['hosts.get_ip'](saltshort) %}
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
