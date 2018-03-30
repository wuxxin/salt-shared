base:
  # host named salt.* or grain salt_master:True or pillar item salt.master.status:present
  'L@salt.* or G@salt_master:True or I@salt:master:status:present':
    - match: compound
    - roles.salt.master

  'tinydns_server:status:present':
    - match: pillar
    - roles.tinydns

  'dhcp_server:status:present':
    - match: pillar
    - roles.dhcp

  'dokku:status:present':
    - match: pillar
    - roles.dokku
