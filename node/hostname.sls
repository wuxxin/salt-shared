{% from "node/defaults.jinja" import settings %}

set_hostsfile:
  host.only:
    - name: {{ settings.network.internal_ip }}
    - hostnames:
      - {{ settings.hostname }}
      - {{ settings.hostname.partition('.')[0] }}

set_hostname:
  cmd.run:
    - name: hostnamectl set-hostname "{{ settings.hostname }}"
    - onlyif: test "$(hostname -f)" != "{{ settings.hostname }}"
    - require:
      - host: set_hostsfile
