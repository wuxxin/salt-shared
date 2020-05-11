{% from "nfs/defaults.jinja" import settings %}

{% macro param_list(param_name, list) %}{% if list %}{{ param_name+ ' '+ list|join(' '+ param_name+ ' ') }}{% endif %}{% endmacro %}

{% set nfs3_option= '' if settings.legacy_support else '-N 3 ' %}
{% set nfs_common_replace = [
  ('STATDOPTS', '--port 32765 --outgoing-port 32766 '+ param_list('--name', settings.listen_ip) ),
  ('NEED_STATD', 'yes' if settings.legacy_support else 'no'),
  ('NEED_IDMAPD', ''),
] %}
{% set nfs_server_replace = [
  ('RPCNFSDOPTS',   '-N 2 '+ nfs3_option+ '--no-udp '+ param_list('--host', settings.listen_ip) ),
  ('RPCMOUNTDOPTS', '-N 2 '+ nfs3_option+ '--no-udp --manage-gids --port 32767'),
] %}
{#  ('fs.nfs.nfs_callback_tcpport', 32764), #}
{% set nfs_sysctl= [
  ('fs.nfs.nlm_tcpport', 32768),
  ('fs.nfs.nlm_udpport', 32768),
] %}


rpcbind:
  pkg.installed:
    - name: rpcbind

{# restrict rpcbind to localhost and default list ([internal_ip]) #}
/etc/default/rpcbind:
  file.replace:
    - pattern: '^OPTIONS=".+"'
    - repl: OPTIONS="-w -l {{ param_list('-h', settings.listen_ip) }}"
    - append_if_not_found: true
    - require:
      - pkg: rpcbind

{# only start rpcbind[.socket] if nfs3 legacy support is required #}
{% if settings.legacy_support %}

  {% if salt['file.is_link']('/etc/systemd/system/rpcbind.socket') %}
absent_rpcbind.socket:
  file.absent:
    - name: /etc/systemd/system/rpcbind.socket
    - require_in:
      - file: rpcbind.socket
  {% endif %}
  {% if salt['file.is_link']('/etc/systemd/system/rpcbind.service') %}
absent_rpcbind.service:
  file.absent:
    - name: /etc/systemd/system/rpcbind.service
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: absent_rpcbind.service
    - require_in:
      - service: unmask_legacy_rpcbind
  {% endif %}

rpcbind.socket:
  file.managed:
    - name: /etc/systemd/system/rpcbind.socket
    - makedirs: true
    - require:
      - pkg: rpcbind
    - contents: |
        [Unit]
        Description=RPCbind Server Activation Socket
        DefaultDependencies=no
        After=network-online.target

        [Socket]
        ListenStream=/run/rpcbind.sock

        # RPC netconfig can't handle ipv6/ipv4 dual sockets
        BindIPv6Only=ipv6-only
  {%- for ip in settings.listen_ip %}
  {%- set ip = '['+ ip+ ']' if ip|is_ipv6 else ip %}
        ListenStream={{ ip }}:111
        ListenDatagram={{ ip }}:111
  {%- endfor %}

        [Install]
        WantedBy=sockets.target
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: rpcbind.socket

unmask_legacy_rpcbind:
  service.unmasked:
    - name: rpcbind
    - require_in:
      - service: legacy_rpcbind

legacy_rpcbind:
  service.running:
    - name: rpcbind
    - enable: True
    - require:
      - file: /etc/default/rpcbind
    - watch:
      - file: /etc/default/rpcbind

legacy_rpcbind.socket:
  service.running:
    - name: rpcbind.socket
    - enable: True
    - require:
      - service: legacy_rpcbind
      - cmd: rpcbind.socket
    - watch:
      - file: rpcbind.socket

{% else %}

legacy_rpcbind.socket:
  service.dead:
    - name: rpcbind.socket
    - enable: False
    - require:
      - pkg: rpcbind

rpcbind.socket:
  file.absent:
    - name: /etc/systemd/system/rpcbind.socket
    - require:
      - service: legacy_rpcbind.socket
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: rpcbind.socket

mask_legacy_rpcbind.socket:
  service.masked:
    - name: rpcbind.socket
    - require:
      - file: rpcbind.socket
      - cmd: rpcbind.socket

legacy_rpcbind:
  service.dead:
    - name: rpcbind
    - enable: False
    - require:
      - file: /etc/default/rpcbind
    - watch:
      - file: /etc/default/rpcbind

mask_legacy_rpcbind:
  service.masked:
    - name: rpcbind
    - require:
      - service: legacy_rpcbind
{% endif %}



nfs-common:
  pkg.installed:
    - name: nfs-common
    - require:
      - service: legacy_rpcbind
      - service: legacy_rpcbind.socket

{% for name, value in nfs_common_replace %}
{{ name }}-nfs-common:
  file.replace:
    - name: /etc/default/nfs-common
    - pattern: '^{{ name }}=.*'
    - repl: {{ name }}="{{ value }}"
    - append_if_not_found: true
    - require:
      - pkg: nfs-common
    - require_in:
      - service: nfs-kernel-server
    - watch_in:
      - service: nfs-kernel-server
{% endfor %}

{% for name, value in nfs_server_replace %}
{{ name }}-nfs-kernel-server:
  file.replace:
    - name: /etc/default/nfs-kernel-server
    - pattern: '^{{ name }}=.*'
    - repl: {{ name }}="{{ value }}"
    - append_if_not_found: true
    - require:
      - pkg: nfs-common
    - require_in:
      - service: nfs-kernel-server
    - watch_in:
      - service: nfs-kernel-server
{% endfor %}

nfs-kernel-server:
  service.running:
    - name: nfs-kernel-server
    - enable: True

{%- if salt['grains.get']('virtual', 'unknown') != 'LXC' %}
  {% for name, value in nfs_sysctl %}
{{ name }}:
  sysctl.present:
    - value: {{ value }}
    - require:
      - pkg: nfs-common
    - require_in:
      - service: nfs-kernel-server
    - watch_in:
      - service: nfs-kernel-server
  {% endfor %}
{% endif %}


/etc/services:
  file.blockreplace: {# XXX file.blockreplace does use "content" instead of "contents" #}
    - marker_start: "# ### NODE.RPC BEGIN ###"
    - marker_end: "# ### NODE.RPC END ###"
    - append_if_not_found: True
    - content: |
       # NFS ports as per the NFS-HOWTO
       # http://www.tldp.org/HOWTO/NFS-HOWTO/security.html#FIREWALLS
       # Listing here does not mean they will bind to these ports.
       rpc.nfsd        2049/tcp                        # RPC nfsd
       rpc.nfsd        2049/udp                        # RPC nfsd
       rpc.nfs-cb      32764/tcp                       # RPC nfs callback
       rpc.nfs-cb      32764/udp                       # RPC nfs callback
       rpc.statd-bc    32765/tcp                       # RPC statd broadcast
       rpc.statd-bc    32765/udp                       # RPC statd broadcast
       rpc.statd       32766/tcp                       # RPC statd listen
       rpc.statd       32766/udp                       # RPC statd listen
       rpc.mountd      32767/tcp                       # RPC mountd
       rpc.mountd      32767/udp                       # RPC mountd
       rpc.lockd       32768/tcp                       # RPC lockd/nlockmgr
       rpc.lockd       32768/udp                       # RPC lockd/nlockmgr
       rpc.quotad      32769/tcp                       # RPC quotad
       rpc.quotad      32769/udp                       # RPC quotad

{#
/usr/lib/systemd/scripts/nfs-utils_env.sh creates /run/sysconfig/nfs-utils
+ /etc/default/nfs-common
  + rpc.statd: --no-notify $STATDARGS=\"$STATDOPTS\"
+ /etc/default/nfs-kernel-server
  + rpc.nfsd: RPCNFSDARGS=\"$RPCNFSDOPTS ${RPCNFSDCOUNT:-8}\"
  + rpc.mountd: $RPCMOUNTDARGS=\"$RPCMOUNTDOPTS\"
  + rpc.svcgssd: $SVCGSSDARGS=\"$RPCSVCGSSDOPTS\"
+ supported but not exposed from nfs-utils_env.sh:
  + sm-notify: SMNOTIFYARGS=\"$SMNOTIFYARGS\"
  + rpc.idmapd: RPCIDMAPDARGS=\"$RPCIDMAPDARGS\"
  + blkmapd: BLKMAPDARGS=\"$BLKMAPDARGS\"
+ uses tcp_wrapper for access control
  + /etc/hosts.deny:
    rpcbind mountd nfsd statd lockd rquotad portmap: ALL
  + /etc/hosts.allow:
    rpcbind mountd nfsd statd lockd rquotad portmap: 127.0.0.1/24
    # nur fuer die IP 192.168.1.13: portmap: 192.168.1.13
    # fuer das gesamte LAN Zugriff: portmap: 192.168.1. oder portmap: 192.168.1.0/24
#}
