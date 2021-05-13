{% from "old/lab/appliance/zentyal/defaults.jinja" import settings with context %}

include:
  - old.lab.appliance.zentyal.base
  - systemd.reload

{# ### install zentyal packages #}
zentyal:
  pkgrepo.managed:
    - name: deb http://archive.zentyal.org/zentyal 5.1 main
    - file: /etc/apt/sources.list.d/zentyal-xenial.list
    - key_url: salt://old/lab/appliance/zentyal/files/zentyal-5.1-archive.asc
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
      - sls: old.lab.appliance.zentyal.base


{# XXX workaround for samba AD needing ext_attr security support not available in an lxc/lxd unprivileged container, this will get overwritten on pkg python-samba update #}
patch-ntacls.py:
  file.managed:
    - name: /usr/lib/python2.7/dist-packages/samba/ntacls.py
    - source: salt://old/lab/appliance/zentyal/files/ntacls.py
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
    - source: salt://old/lab/appliance/zentyal/files/ssl.conf
    - require_in:
      - file: zentyal-apache-enable-ssl.conf

{% for i in ['proxy.conf', 'proxy.load', 'proxy_http.load', 'rewrite.load',
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
{%- set gwip = salt['network.default_route']('inet')[0]['gateway'] %}
{%- set gwdev = salt['network.default_route']('inet')[0]['interface'] %}
{%- set address = salt['network.ip_addrs'](gwdev)[0] %}
{%- set netmask = salt['network.convert_cidr'](salt['network.subnets'](gwdev)[0])['netmask'] %}
{%- set broadcast = salt['network.interface'](gwdev)[0]['broadcast'] %}
{%- set dns_nameservers = salt['grains.get']('dns:nameservers') %}
{%- set dns_search = salt['grains.get']('dns:search') %}
{%- set match = settings.domain|regex_search('[^.]+\.(.+)') %}
{%- set basedomain = match[0] %}

temporary-shutdown-docker:
  service.dead:
    - name: docker
    - onlyif: grep -q "source /etc/network/interfaces.d/\*.cfg" /etc/network/interfaces

temporary-shutdown-other-interfaces:
  cmd.run:
    - name: for a in $(ifquery --list); do if test "$a" != "lo" -a "$a" != "eth0"; then ifdown $a; fi; done
    - onlyif: grep -q "source /etc/network/interfaces.d/\*.cfg" /etc/network/interfaces
    - require:
      - service: temporary-shutdown-docker

zentyal-interfaces:
  cmd.run:
    - name: |
        cat - <<"EOF"
        # zentyal hardcoded interface list
        auto lo {{ gwdev }}
        iface lo inet loopback

        iface {{ gwdev }} inet static
            address {{ address }}
            netmask {{ netmask }}
            broadcast {{ broadcast }}
            gateway {{ gwip }}
            dns-nameservers {{ dns_nameservers|join(' ') }}
            dns-search {{ dns_search|join(' ') }}

        EOF

    - onlyif: grep -q "source /etc/network/interfaces.d/\*.cfg" /etc/network/interfaces
    - require:
      - cmd: temporary-shutdown-other-interfaces

zentyal-resolv.conf:
  cmd.run:
    - name: |
        resolvconf -a << EOF
        nameserver {{ dns_nameservers|join(' ') }}
        search {{ dns_search|join(' ') }}
        EOF
        resolvconf -u
    - onlyif: '! grep -q "nameserver {{ dns_nameservers[0] }}" /etc/resolv.conf'

bind9-disable-resolvconf-addition:
  file.managed:
    - name: /etc/systemd/system/bind9-resolvconf.service.d/fix-no-bind-dns.conf
    - makedirs: True
    - contents: |
        # systemd drop-in for bind9-resolvconf.service
        # XXX do not set bind9 as local dns resolver, zentyal grabs basedomain from hostname as own domain for kerberus/ldap dns stuff
        [Service]
        ExecStart=
        ExecStop=

    - onchanges_in:
      - cmd: systemd_reload

{# XXX write out a customized zentyal redis config setter #}
/usr/local/sbin/prepare-zentyal-config.sh:
  file.managed:
    - source: salt://old/lab/appliance/zentyal/files/prepare-zentyal-config.sh
    - template: jinja
    - defaults:
        fqdn: {{ settings.domain }}
        domain: {{ basedomain }}
        interface: {{ gwdev }}
        address: {{ address }}
        netmask: {{ netmask }}
        broadcast: {{ broadcast }}
        gateway: {{ gwip }}
        nameserver: {{ dns_nameservers[0] }}
        dnssearch: {{ dns_search[0] }}
    - mode: "755"
    - onlyif: test -e /var/lib/zentyal/.first
    - unless: test -e /usr/local/sbin/prepare-zentyal-config.sh
