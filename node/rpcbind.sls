{% from "node/defaults.jinja" import settings %}

{# restrict rpcbind to localhost and default list ([internal_ip]) #}
rpcbind:
  pkg.installed:
    - name: rpcbind
  file.replace:
    - name: /etc/default/rpcbind
    - pattern: '^OPTIONS=".+"'
    - repl: OPTIONS="-w -l -h 127.0.0.1 -h ::1 {% for ip in settings.network.rpc_bind_list %}-h {{ ip }}{% endfor %}"
    - append_if_not_found: true
    - require:
      - pkg: rpcbind
  service.running:
    - name: rpcbind
    - enable: True
    - require:
      - file: rpcbind
      - cmd: bridge_{{ settings.network.internal_name }}
      - cmd: default_netplan
    - watch:
      - file: rpcbind

rpcbind.socket:
  file.managed:
    - name: /etc/systemd/system/rpcbind.socket
    - makedirs: true
    - contents: |
        [Unit]
        Description=RPCbind Server Activation Socket
        DefaultDependencies=no
        After=network-online.target

        [Socket]
        ListenStream=/run/rpcbind.sock

        # RPC netconfig can't handle ipv6/ipv4 dual sockets
        BindIPv6Only=ipv6-only
        ListenStream=127.0.0.1:111
        ListenDatagram=127.0.0.1:111
        ListenStream=[::1]:111
        ListenDatagram=[::1]:111
{%- for ip in settings.network.rpc_bind_list %}
        ListenStream={{ ip }}:111
        ListenDatagram={{ ip }}:111
{%- endfor %}
        [Install]
        WantedBy=sockets.target
    - require:
      - pkg: rpcbind
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: rpcbind.socket
  service.running:
    - name: rpcbind.socket
    - enable: True
    - require:
      - cmd: rpcbind.socket
      - cmd: bridge_{{ settings.network.internal_name }}
      - cmd: default_netplan
    - watch:
      - file: rpcbind.socket

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
uses tcp_wrapper for access control
+ /etc/default/nfs-common
  + rpc.statd: --no-notify $STATDARGS=\"$STATDOPTS\"
    + --port 32765 --outgoing-port 32766 --name 127.0.0.1
+ /etc/default/nfs-kernel-server
  + rpc.nfsd: RPCNFSDARGS=\"$RPCNFSDOPTS ${RPCNFSDCOUNT:-8}\"
    + --host hostname --port 2049 --rdma 20049 --no-tcp --no-udp
  + rpc.mountd: $RPCMOUNTDARGS=\"$RPCMOUNTDOPTS\"
    + --no-udp and --no-tcp
  + rpc.svcgssd: $SVCGSSDARGS=\"$RPCSVCGSSDOPTS\"
+ supported but not exposed from nfs-utils_env.sh:
  + sm-notify: SMNOTIFYARGS=\"$SMNOTIFYARGS\"
  + rpc.idmapd: RPCIDMAPDARGS=\"$RPCIDMAPDARGS\"
  + blkmapd: BLKMAPDARGS=\"$BLKMAPDARGS\"
+ /etc/hosts.deny:
    rpcbind mountd nfsd statd lockd rquotad portmap: ALL
+ /etc/hosts.allow:
    rpcbind mountd nfsd statd lockd rquotad portmap: 127.0.0.1/24
    # nur fuer die IP 192.168.1.13: portmap: 192.168.1.13
    # fuer das gesamte LAN Zugriff: portmap: 192.168.1. oder portmap: 192.168.1.0/24
#}


nfs-common:
  pkg.installed:
    - name: nfs-common
    - require:
      - service: rpcbind
      - service: rpcbind.socket

{% set rpc_bind_string = '' %}
{% if settings.network.rpc_bind_list %}
  {% set rpc_bind_string = ' --name '+ settings.network.rpc_bind_list|join(' --name ') %}
{% endif %}

{% for name, value in [
  ('STATDOPTS', '--port 32765 --outgoing-port 32766 --name 127.0.0.1 --name ::1'+ rpc_bind_string),
  ('NEED_STATD', 'no'),
  ('NEED_IDMAPD', 'yes'),
] %}
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

{% set rpc_bind_string = '' %}
{% if settings.network.rpc_bind_list %}
  {% set rpc_bind_string = ' --host '+ settings.network.rpc_bind_list|join(' --host ') %}
{% endif %}

{% for name, value in [
  ('RPCNFSDOPTS', '-N 2 -N 3 --no-udp --host 127.0.0.1 --host ::1'+ rpc_bind_string),
  ('RPCMOUNTDOPTS', '-N 2 -N 3 --manage-gids --port 32767 --no-udp'),
] %}
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
    - require:
      - cmd: bridge_{{ settings.network.internal_name }}
      - cmd: default_netplan

{#  ('fs.nfs.nfs_callback_tcpport', 32764), #}
{%- if salt['grains.get']('virtual', 'unknown') != 'LXC' %}
  {% for name, value in [
    ('fs.nfs.nlm_tcpport', 32768),
    ('fs.nfs.nlm_udpport', 32768) ] %}
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
