#!/bin/bash

if test ! -e /var/lib/zentyal/.first; then
    echo "WARNING: zentyal/.first does not exist, abort $0"
    exit 0
fi

echo "stopping main zentyal processes"
zs stop

echo -n "Reset config of modules: "
for i in antivirus audit dns firewall logs mail mailfilter network ntp samba sogo sysinfo webadmin; do
    echo -n "$i "
    /usr/share/zentyal/clean-conf $i
done
echo "."

echo "Rewrite interfaces as static"
cat > /etc/network/interfaces << EOF
auto lo

iface lo inet loopback

auto {{ interface }}
iface {{ interface }} inet static
      address {{ address }}
      netmask {{ netmask }}
      broadcast {{ broadcast }}
      gateway {{ gateway }}
      dns-nameservers {{ nameserver }}
      dns-search {{ dnssearch }}

EOF

echo "Rewrite resolv.conf"
resolvconf -a {{ interface }} << EOF
nameserver {{ nameserver }}
search {{ dnssearch }}

EOF
if test -e /var/run/resolvconf/interface/lo.domain; then
    rm /var/run/resolvconf/interface/lo.domain
fi
resolvconf -u

# write out seed config
cat > /etc/zentyal/seed.yaml <<"EOF"
global/conf/modules/dns/changed:
  type: string
  value: '1'
global/conf/modules/mail/changed:
  type: string
  value: '1'
global/conf/modules/mailfilter/changed:
  type: string
  value: '1'
global/conf/modules/network/changed:
  type: string
  value: '1'
global/conf/modules/ntp/changed:
  type: string
  value: '1'
global/conf/modules/samba/changed:
  type: string
  value: '1'
global/conf/modules/sogo/changed:
  type: string
  value: '1'

dns/state:
  type: string
  value: '{"_serviceConfigured":0,"_needsSaveAfterConfig":1}'
mail/state:
  type: string
  value: '{"_serviceConfigured":0,"_needsSaveAfterConfig":1}'
mailfilter/state:
  type: string
  value: '{"_serviceConfigured":0,"_needsSaveAfterConfig":1}'
network/state:
  type: string
  value: '{"_serviceConfigured":0,"_needsSaveAfterConfig":1}'
ntp/state:
  type: string
  value: '{"_serviceConfigured":0,"_needsSaveAfterConfig":1}'
samba/state:
  type: string
  value: '{"_serviceConfigured":0,"_needsSaveAfterConfig":1}'
sogo/state:
  type: string
  value: '{"_serviceConfigured":0,"_needsSaveAfterConfig":1}'

antivirus/conf/_serviceModuleStatus:
  type: string
  value: '0'
dns/conf/_serviceModuleStatus:
  type: string
  value: '0'
logs/conf/_serviceModuleStatus:
  type: string
  value: '0'
mail/conf/_serviceModuleStatus:
  type: string
  value: '0'
mailfilter/conf/_serviceModuleStatus:
  type: string
  value: '0'
network/conf/_serviceModuleStatus:
  type: string
  value: '0'
ntp/conf/_serviceModuleStatus:
  type: string
  value: '0'
samba/conf/_serviceModuleStatus:
  type: string
  value: '0'
sogo/conf/_serviceModuleStatus:
  type: string
  value: '0'
  
samba/conf/AccountSettings/keys/form:
  type: string
  value: '{"defaultQuota_selected":"defaultQuota_disabled","defaultQuota_size":500}'

ntp/conf/Settings/keys/form:
  type: string
  value: '{"sync":0}'

mail/conf/RetrievalServices/keys/form:
  type: string
  value: '{"managesieve":1,"pop3s":1,"imap":0,"imaps":1,"fetchmail":1,"pop3":0}'
mail/conf/SMTPOptions/bounceReturnAddress:
  type: string
  value: noreply@{{ domain }}
mail/conf/VDomainAliases/max_id:
  type: string
  value: '1'
mail/conf/VDomains/keys/vd1:
  type: string
  value: '{"vdomain":"{{ domain }}"}'
mail/conf/VDomains/keys/vd1/aliases/keys/vdm1:
  type: string
  value: '{"alias":"{{ fqdn }}"}'
mail/conf/VDomains/keys/vd1/aliases/order:
  type: string
  value: '["vdm1"]'
mail/conf/VDomains/max_id:
  type: string
  value: '1'
mail/conf/VDomains/order:
  type: string
  value: '["vd1"]'

network/conf/BalanceGateways/keys/blnc1:
  type: string
  value: '{"name":"gw-{{ interface }}","enabled":1}'
network/conf/BalanceGateways/max_id:
  type: string
  value: '1'
network/conf/BalanceGateways/order:
  type: string
  value: '["blnc1"]'

network/conf/DNSResolver/keys/dnsr1:
  type: string
  value: '{"nameserver":"{{ nameserver }}","interface":"zentyal.dnsr1"}'
network/conf/DNSResolver/max_id:
  type: string
  value: '1'
network/conf/DNSResolver/order:
  type: string
  value: '["dnsr1"]'

network/conf/GatewayTable/keys/gtw1:
  type: string
  value: '{"ip":"{{ gateway }}","interface":"{{ interface }}", "name":"gw-{{ interface }}","default":1,"auto":0,"weight":1,"enabled":1}'
network/conf/GatewayTable/max_id:
  type: string
  value: '1'
network/conf/GatewayTable/order:
  type: string
  value: '["gtw1"]'

network/conf/default/gateway:
  type: string
  value: gtw1
network/conf/interfaces:
  type: string
  value: '{"{{ interface }}":{"name":"{{ interface }}","method":"static","netmask":"{{ netmask }}","address":"{{ address }}","external":1}}'
network/conf/SearchDomain/keys/form:
  type: string
  value: '{"domain":"{{ dnssearch }}","interface":"zentyal.form"}'


EOF

echo "import /etc/zentyal/seed.yaml into redis"
cat /etc/zentyal/seed.yaml | python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, sort_keys=True)' | redis-load 

