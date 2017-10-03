base:
  # host named salt.* or grain salt_master:True or pillar item salt.master.status:present
  'L@salt.* or G@salt_master:True or I@salt:master:status:present':
    - match: compound
    - roles.salt.master

  'dns_server:status:present':
    - match: pillar
    - roles.dns

  'tinydns_server:status:present':
    - match: pillar
    - roles.tinydns

  'dhcp_server:status:present':
    - match: pillar
    - roles.dhcp

  'apt-cacher-ng:server:status:present':
    - match: pillar
    - roles.apt-cacher-ng

  'apt-cacher-ng:client:status:present':
    - match: pillar
    - roles.apt-cacher-ng.client

  'docker:status:present':
    - match: pillar
    - roles.docker

  'dokku:status:present':
    - match: pillar
    - roles.dokku

  'libvirt:status:present':
    - match: pillar
    - roles.libvirt

  'openvpn_server:status:present':
    - match: pillar
    - roles.openvpn

  'imgbuilder:status:present':
    - match: pillar
    - roles.imgbuilder

  'snapshot-backup:status:present':
    - match: pillar
    - roles.snapshot-backup

  'backupninja:status:present':
    - match: pillar
    - roles.backupninja

  'zentyal:status:present':
    - match: pillar
    - roles.zentyal

  'desktop:status:present':
    - match: pillar
    - roles.desktop
