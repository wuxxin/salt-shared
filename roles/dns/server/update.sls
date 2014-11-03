
odns-server-update-client:
  cmd.run:
    - name: dnsupdate {{ pillar.dns.update.name }} {{ pillar.dns.update.ip }} {{ pillar.dns.update.type }}
