base:
  # host named salt.* or grain salt_master:True or pillar item salt.master.status:present
  'L@salt.* or G@salt_master:True or I@salt:master:status:present':
    - match: compound
    - roles.salt.master

  'dns_server:status:present':
    - match: pillar
    - roles.dns

  'dns_server:status:absent':
    - match: pillar
    - roles.dns.absent

  'tinydns_server:status:present':
    - match: pillar
    - roles.tinydns

  'tinydns_server:status:absent':
    - match: pillar
    - roles.tinydns.absent

  'dhcp_server:status:present':
    - match: pillar
    - roles.dhcp

  'dhcp_server:status:absent':
    - match: pillar
    - roles.dhcp.absent

  'shorewall:status:present':
    - match: pillar
    - roles.shorewall

  'libvirt:status:present':
    - match: pillar
    - roles.libvirt

  'openvpn_server:status:present':
    - match: pillar
    - roles.openvpn

  'imgbuilder:status:present':
    - match: pillar
    - roles.imgbuilder

  #'snapshot_backup:status:present':
  #  - match: pillar
  #  - roles.snapshot_backup

  'backupninja:status:present':
    - match: pillar
    - roles.backupninja

  'zentyal:status:present':
    - match: pillar
    - roles.zentyal

  'zentyal_sogo:status:present':
    - match: pillar
    - roles.zentyal_sogo

  'G@gitlab_status:present or I@gitlab:status:present':
    - match: compound
    - roles.gitlab

  'desktop:status:present':
    - match: pillar
    - roles.desktop
