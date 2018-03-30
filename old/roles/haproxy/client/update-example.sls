
test_update:
  event.fire_master:
    - name: "proxy/client/update"
    - data:
        hostname: {{ grains['fqdn'] }}
        ip: {{ grains['ipv4'] | first() }}
        frontend: default_https
        backend_port: 443
        options: None
