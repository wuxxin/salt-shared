{% from "node/defaults.jinja" import settings %}

set_hostsfile:
  host.only:
    - name: {{ settings.network.internal.ip }}
    - hostnames:
      - {{ settings.hostname.partition('.')[0] }}
      - {{ settings.hostname.partition('.')[0] ~ "." ~ settings.network.internal.name }}

set_hostname:
  cmd.run:
    - name: hostnamectl set-hostname "{{ settings.hostname }}"
    - onlyif: test "$(hostname -f)" != "{{ settings.hostname }}"
    - require:
      - host: set_hostsfile
