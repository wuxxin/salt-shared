# metric and logging collection

+ metric collection service and alert generation
    + victoriametrics, vmagent, vmalert and alertmanager
+ local node metric export
    + node_exporter and additional exporter for postgres,mysql,redis and mtail grok
+ syslog/journald collection
    + promtail for export and loki for colleciton
    + fail2ban for filter and action on log
+ grafana as gui for metric and syslog collection


## notes unsorted

image: grafana/fluent-bit-plugin-loki:latest
environment:
  LOKI_URL: http://loki:3100/loki/api/v1/push
volumes:
  - ./fluent-bit.conf:/fluent-bit/etc/fluent-bit.conf
ports:
  - "24224:24224"
  - "24224:24224/udp"
