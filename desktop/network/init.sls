include:
  - .iperf3
  
desktop_network_packages:
  pkg.installed:
    - pkgs:
      - wireshark
      - snmp-mibs-downloader
      - ostinato
      - netperf     {# Network performance benchmark #}
  
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("flent-ppa", "tohojo/flent",
  require_in = "pkg:flent") }}
  
flent:
  pkg:
    - installed
    - require:
      - pkg: iperf3
