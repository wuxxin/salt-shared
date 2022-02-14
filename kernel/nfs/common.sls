{% from "kernel/nfs/defaults.jinja" import settings %}

{% macro param_list(param_name, list) %}{% if list %}{{ param_name+ ' '+ list|join(' '+ param_name+ ' ') }}{% endif %}{% endmacro %}

{% set nfs_common_replace = [
  ('STATDOPTS', '--port 32765 --outgoing-port 32766 '+ param_list('--name', settings.listen_ip) ),
  ('NEED_STATD', 'no'),
  ('NEED_IDMAPD', ''),
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

rpcbind.socket:
  service.dead:
    - name: rpcbind.socket
    - enable: False
    - require:
      - pkg: rpcbind
  file.absent:
    - name: /etc/systemd/system/rpcbind.socket
    - require:
      - service: rpcbind.socket
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: rpcbind.socket

mask_rpcbind.socket:
  service.masked:
    - name: rpcbind.socket
    - require:
      - file: rpcbind.socket
      - cmd: rpcbind.socket

rpcbind.service:
  service.dead:
    - name: rpcbind.service
    - enable: False
    - require:
      - file: /etc/default/rpcbind
    - watch:
      - file: /etc/default/rpcbind

mask_rpcbind.service:
  service.masked:
    - name: rpcbind.service
    - require:
      - service: rpcbind.service

nfs-common:
  pkg.installed:
    - name: nfs-common
    - require:
      - service: rpcbind.service
      - service: rpcbind.socket

{% for name, value in nfs_common_replace %}
{{ name }}-nfs-common:
  file.replace:
    - name: /etc/default/nfs-common
    - pattern: '^{{ name }}=.*'
    - repl: {{ name }}="{{ value }}"
    - append_if_not_found: true
    - require:
      - pkg: nfs-common
{% endfor %}

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
