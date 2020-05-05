{% from "node/defaults.jinja" import settings %}

set_hostsfile:
  host.only:
    - name: {{ settings.bridge_ip }}
    - hostnames:
      - {{ salt['pillar.get']('hostname') }}
      - {{ salt['pillar.get']('hostname').partition('.')[0] }}

set_hostname:
  cmd.run:
    - name: hostnamectl set-hostname "{{ salt['pillar.get']('hostname') }}"
    - onlyif: test "$(hostname -f)" != "{{ salt['pillar.get']('hostname') }}"
    - require:
      - host: set_hostsfile
