base:
  # host named salt.* or grain salt_master:True or pillar item salt.master.status:present
  'L@salt.* or G@salt_master:True or I@salt:master:status:present':
    - match: compound
    - roles.salt.master

  'desktop:status:present':
    - match: pillar
    - roles.desktop

  'dns_server:status:present':
    - match: pillar
    - roles.dns

  'tinydns_server:status:present':
    - match: pillar
    - roles.tinydns

  'dns_server:status:absent':
    - match: pillar
    - roles.dns.absent

  'tinydns_server:status:absent':
    - match: pillar
    - roles.tinydns.absent

  'dhcp_server:status:present':
    - match: pillar
    - roles.dhcp

  'dhcp_server:status:absent':
    - match: pillar
    - roles.dhcp.absent

  'libvirt:status:present':
    - match: pillar
    - roles.libvirt

  'imgbuilder:status:present':
    - match: pillar
    - roles.imgbuilder

  #'snapshot_backup:status:present':
  #  - match: pillar
  #  - roles.snapshot_backup

  'backupninja:status:present':
    - match: pillar
    - roles.backupninja

  'openvpn_server:status:present':
    - match: pillar
    - roles.openvpn

  'shorewall:status:present':
    - match: pillar
    - roles.shorewall

  'zentyal:status:present':
    - match: pillar
    - roles.zentyal

  'zentyal_sogo:status:present':
    - match: pillar
    - roles.zentyal_sogo

  'G@gitlab_status:present or I@gitlab:status:present':
    - match: compound
    - roles.gitlab
