{% from "lab/appliance/zentyal/defaults.jinja" import settings with context %}

include:
  - ubuntu
  - python
  - appliance

{%- set password= settings.admin.password or salt['cmd.run_stdout']('openssl rand 8 -hex') %}
zentyal-admin-user:
  user.present:
    - name: {{ settings.admin.user }}
    - groups:
      - adm
      - sudo
    - remove_groups: False
    - password: {{ salt.shadow.gen_password(password) }}
    - unless: getent passwd {{ settings.admin.user }}

{# ### zentyal templates #}
{% for n in ['core/nginx.conf.mas',
  'mail/main.cf.mas', 'mail/master.cf.mas', 'mail/dovecot.conf.mas',
  'samba/smb.conf.mas', 'samba/shares.conf.mas'] %}
/etc/zentyal/stubs/{{ n }}:
  file.managed:
    - source: salt://lab/appliance/zentyal/files/stubs/{{ n }}
    - makedirs: true
{% endfor %}

{# ### zentyal hooks #}
{% for n in ['webadmin', 'mail', 'sogo'] %}
/etc/zentyal/hooks/{{ n }}.postsetconf:
  file.managed:
    - source: salt://lab/appliance/zentyal/files/hooks/{{ n }}.postsetconf
    - template: jinja
    - defaults: 
        settings: {{ settings }}
    - mode: "755"
    - makedirs: true
{% endfor %}

{# ### zentyal config #}
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

{# ### create a private samba network so samba is not exposed on eth0 #}
samba-network:
  pkg.installed:
    - pkgs:
      - bridge-utils
  file.managed:
    - name: /etc/network/interfaces.d/90-samba-bridge.cfg
    - contents: |
        auto sambabr0
        iface sambabr0 inet static
            address {{ settings.samba.bridge.ipaddr }}
            netmask {{ settings.samba.bridge.netmask }}
            bridge_ports none
            bridge_stp off
            bridge_maxwait 0
            
    - require:
      - pkg: samba-network
  cmd.run:
    - name: ifup sambabr0
    - unless: ifquery --read-environment --verbose --state sambabr0
    - onchanges:
      - file: samba-network

{# ### disable warning flooding logs #}
sogo-tmpreaper:
  file.managed:
    - name: /etc/tmpreaper.conf
    - contents: |
        # tmpreaper.conf                                 
        # - local configuration for tmpreaper's daily run
        SHOWWARNING=false
        TMPREAPER_PROTECT_EXTRA=''
        TMPREAPER_DIRS='/tmp/.'
        TMPREAPER_DELAY='256'
        TMPREAPER_ADDITIONALOPTIONS=''

{# ### helper to convert mbox to maildir #}
/usr/local/bin/mb2md.pl:
  file.managed:
    - source: salt://lab/appliance/zentyal/files/mb2md.pl
    - mode: "0755"

{# ### helper to preseed zentyal redis config #}
{% from 'python/lib.sls' import pip3_install %}
{{ pip3_install('redis-dump-load') }}
