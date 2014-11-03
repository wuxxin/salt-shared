
test_update:
  event.fire_master:
    - name: dns/client/update
    - data:
      hostname: {{ pillar.hostname }}
      ip: {{ grains['ipv4'] | first() }}
      type: A

