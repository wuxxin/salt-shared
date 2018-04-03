# Zentyal 5.x Mail server

Zentyal 5.1 Mailserver with the following additions:

+ support for automatic letsencrypt certificates
+ opendkim support
+ integrated in appliance state

## FIXME

+ local user should have maildir
+ ssl on port 465 (postfix smtps)
+ storage: 
  + add /data storage volume
  + move /var/backups, cache, crash, lib, local, log, mail, opt, snap, spool, tmp, vmail, www to /data/var/*
  + move /tmp to /data/tmp
  
+ /var/lib/zentyal/.first is flag
+ samba bind to localhost: smbd (445,139), nmbd (137,138)
+ ntp not working in lxc ?
+ firewall: kernelmodules
    8021q ip_conntrack_ftp ip_nat_ftp ip_conntrack_tftp nf_conntrack_ftp 
    nf_nat_ftp nf_conntrack_h323 nf_nat_h323 nf_conntrack_pptp nf_nat_pptp 
    nf_conntrack_sip nf_nat_sip
+ firewall no /proc/sys/net/ipv4/tcp_syncookies

## todo
+ use wkd-hosting: https://wiki.gnupg.org/WKDHosting
+ use rspamd instead of spamassassin
+ use email autoconfig 

## client

imap: username: username@domainname
smtp: username: username@domainname
File:new calender: in the network: format: faldav, offline_support=true
url: https://hostname/SOGo/dav/username@domainname/Calendar/personal
file:new remote addressbook: https://hostname/SOGo/dav/username@domainname/Contacts/personal

## pillar example

```
{%- from 'lib/minivault.sls' import manage_secret, rsa_public_from_secret %}
{%- set dkim_secretkey= manage_secret('dkim_secretkey', 'rsa_secret') %}
{%- set dkim_publickey= rsa_public_from_secret(dkim_secretkey) %}

# change dns
# @   IN  A     1.2.3.4
# @   IN  MX    10  @
# @   IN  TXT   "v=spf1 a mx ptr -all"
# default._domainkey    IN  TXT   ("v=DKIM1; k=rsa; s=email; "
#    "p={{ dkim_publickey[:250] }}"
#    "{{ dkim_publickey[250:] }}")
# for gui-dns: default.domainkey:v=DKIM1; k=rsa; s=email; p={{ dkim_publickey }}
# 4.3.2.1.in-addr.arpa. IN  PTR  {{ domain }}.

dehydrated:
  pillar: appliance:zentyal:letsencrypt

appliance:
  zentyal:
    domain: {{ domain }}
    letsencrypt:
      enabled: true
      domains:
        - {{ domain }} 
      apache: true
      contact_email: {{ adminemail }}
      hook: /usr/local/etc/dehydrated/zentyal-dehydrated-hook.sh
    dkim:
      key: |
{{ dkim_secretkey|indent(10,True) }}
      dns: |
          default._domainkey    IN  TXT   ("v=DKIM1; k=rsa; s=email; "
            "p={{ dkim_publickey[:250] }}"
            "{{ dkim_publickey[250:] }}")
    admin:
      user: admin
      password: {{ manage_secret('zentyal_admin_password', hostname= common.id) }}
```

## Toolbox

get all config vars:
```
cd /usr/share/perl5/EBox
grep -E "EBox::Config::(boolean|configkey)" -R * | sed -r "s#^([^./]+).+::Config::([^(]+)\('?([^')]+).*#\1:\3 (\2)#g" | sort > ~/zentyal-config.txt
```

fix_mailfilter:
  cmd.run:
    - name: echo "DROP DATABASE spamassassin;" | mysql --defaults-file=/etc/mysql/debian.cnf; /usr/share/zentyal-mailfilter/create-spamassassin-db

generate_new_mail_config:
  cmd.run:
    - name: /etc/init.d/zentyal mail restart

+ install lightning: https://addons.mozilla.org/de/thunderbird/addon/lightning/
+ install sogo connector or sogo integrator
  + https://sogo.nu/files/downloads/SOGo/Thunderbird/sogo-connector-31.0.5.xpi
  + https://sogo.nu/files/downloads/SOGo/Thunderbird/sogo-integrator-31.0.5-sogo-demo.xpi

salt-call state.sls roles.zentyal; /etc/init.d/zentyal mail restart; /etc/init.d/postfix restart

create mailboxes:
  doveadm mailbox create public.incoming.2012 -u postmaster@domain
  doveadm mailbox create public.sent.2012 -u postmaster@domain

create sieve of x@domain:
  rule:[delete_from_to_same]
  if allof (not header :contains "To" "postmaster_public/incoming@domain", not header :contains "To" "postmaster_public/sent@domain", header :contains "To" "domain", header :contains "From" "domain")
  {
    discard;
    stop;
  }
