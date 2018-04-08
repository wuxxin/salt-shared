{% from "lab/appliance/zentyal/defaults.jinja" import settings with context %}

include:
  - lab.appliance.zentyal.base

{# ### install zentyal packages #}
zentyal:
  pkgrepo.managed:
    - name: deb http://archive.zentyal.org/zentyal 5.1 main
    - file: /etc/apt/sources.list.d/zentyal-xenial.list
    - key_url: salt://lab/appliance/zentyal/files/zentyal-5.1-archive.asc
    - require:
      - pkg: ppa_ubuntu_installer
    - require_in:
      - pkg: zentyal

  pkg.installed:
    - pkgs:
      - zentyal
      - zentyal-groupware
      - zentyal-samba
      - zentyal-mail
      - zentyal-sogo
      - zentyal-antivirus
      - zentyal-mailfilter
{%- if settings.languages %}
{%- for i in settings.languages %}
{%- if i != 'en' %}
      - language-pack-zentyal-{{ i }}
{%- endif %}
{%- endfor %}
{%- endif %}
    - require:
      - sls: lab.appliance.zentyal.base


{# XXX workaround for samba AD needing ext_attr security support not available in an lxc/lxd unprivileged container, this will get overwritten on pkg python-samba update #}
patch-ntacls.py:
  file.managed:
    - name: /usr/lib/python2.7/dist-packages/samba/ntacls.py
    - source: salt://lab/appliance/zentyal/files/ntacls.py
    - makedirs: true
  cmd.run:
    - name: rm /usr/lib/python2.7/dist-packages/samba/ntacls.pyc; python2 -c "import compileall; compileall.compile_file('/usr/lib/python2.7/dist-packages/samba/ntacls.py')"
    - onchanges:
      - file: patch-ntacls.py

{# ### disable system nginx from starting, would listen on port 80, which conflicts with apache, zentyal only uses custom nginx under /var/lib/zentyal #}
disable-system-nginx:
  service.dead:
    - name: nginx
    - enable: false
mask-system-nginx:
  service.masked:
    - name: nginx

{# ### apache #}  
{# XXX activate needed apache modules, so apache is config is valid, and service is available for letsencrypt #}
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


{# XXX workaround zentyal limitation not including "source" statements in /etc/network/interfaces by concating into interfaces and getting confused if external interface is configured via dhcp #}
{% set gwip = salt['network.default_route']('inet')[0]['gateway'] %}
{% set gwdev = salt['network.default_route']('inet')[0]['interface'] %}
{% set address = salt['network.ip_addrs'](gwdev)[0] %}
{% set netmask = salt['network.convert_cidr'](salt['network.subnets'](gwdev)[0])['netmask'] %}

concat-interfaces:
  cmd.run:
    - name: |
        cat - /etc/network/interfaces.d/90-samba-bridge.cfg /etc/network/interfaces.d/80-docker-bridge.cfg > /etc/network/interfaces <<"EOF"
        # zentyal hardcoded interface list
        auto lo
        iface lo inet loopback
        
        auto {{ gwdev }}
        iface {{ gwdev }} inet static
            address {{ address }}
            netmask {{ netmask }}
            gateway {{ gwip }}
            dns-nameservers {{ salt['grains.get']('dns:nameservers')|join(' ') }}
            dns-search {{ salt['grains.get']('dns:search')|join(' ') }}
        EOF
  
    - onlyif: grep -q "source /etc/network/interfaces.d/\*.cfg" /etc/network/interfaces

{# XXX both scripts try to access zentyal config not yet started while booting the machine. disabled #}
{#
zentyal-dhcp-enter:
  file.absent:
    - name: /etc/dhcp/dhclient-enter-hooks.d/zentyal-dhcp-enter
zentyal-dhcp-exit:
  file.absent:
    - name: /etc/dhcp/dhclient-exit-hooks.d/zentyal-dhcp-exit
#}
