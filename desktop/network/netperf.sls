netperf:
  pkg:
    - installed
  service.dead:
    - enable: False

mask-netperf:
  service.masked:
    - name: netperf
