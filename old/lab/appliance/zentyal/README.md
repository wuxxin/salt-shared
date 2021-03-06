# Zentyal 5.x Mail server

Zentyal 5.1 Mailserver with the following additions:

+ support for automatic letsencrypt certificates
+ opendkim support
+ preseeding config

## testing

## FIXME

+ disabled zentyal:storage for now, makes circular dependency

+ thunderbird/lightning: Can't dismiss missed reminders for recurring events (CalDAV)
    + https://bugzilla.mozilla.org/show_bug.cgi?id=769118
    + https://bugzilla.mozilla.org/show_bug.cgi?id=1344068

## todo

+ make more than one mail domain configurable (opendkim, letsencrypt, postfix, amavis)
    + https://edoceo.com/howto/opendkim
    + https://linode.com/docs/email/postfix/configure-spf-and-dkim-in-postfix-on-debian-8/
+ use wkd-hosting: https://wiki.gnupg.org/WKDHosting
+ use rspamd instead of spamassassin
+ use email autoconfig 

## client

+ imap username: username@domainname
+ smtp username: username@domainname

+ thunderbird:
    + install lightning: https://addons.mozilla.org/de/thunderbird/addon/lightning/
    + install sogo connector or sogo integrator: https://sogo.nu/files/downloads/SOGo/Thunderbird/sogo-connector-31.0.5.xpi

    + add calendar to thunderbird:
        + File:new calender: in the network: format: caldav, offline_support=true
        + url: https://hostname/SOGo/dav/username/Calendar/personal
    + add addressbook to thunderbird:
        + file:new remote addressbook: https://hostname/SOGo/dav/username/Contacts/personal

+ davdroid:
    + baseurl = https://hostname/SOGo/dav
    + username: username

## pillar example

```
{%- from 'lib/minivault.sls' import manage_secret, rsa_public_from_secret %}
{%- set dkim_secretkey= manage_secret('dkim_secretkey', 'rsa_secret') %}
{%- set dkim_publickey= rsa_public_from_secret(dkim_secretkey) %}

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

+ get all config vars:
```
cd /usr/share/perl5/EBox
grep -E "EBox::Config::(boolean|configkey)" -R * | sed -r "s#^([^./]+).+::Config::([^(]+)\('?([^')]+).*#\1:\3 (\2)#g" | sort > ~/zentyal-config.txt
```

+ fix_mailfilter:
  cmd.run:
    - name: echo "DROP DATABASE spamassassin;" | mysql --defaults-file=/etc/mysql/debian.cnf; /usr/share/zentyal-mailfilter/create-spamassassin-db

+ generate_new_mail_config:
  cmd.run:
    - name: zs mail restart

+ create mailboxes:
  doveadm mailbox create public.incoming.2012 -u postmaster@domain
  doveadm mailbox create public.sent.2012 -u postmaster@domain

+ create sieve of x@domain:
  rule:[delete_from_to_same]
  if allof (not header :contains "To" "postmaster_public/incoming@domain", not header :contains "To" "postmaster_public/sent@domain", header :contains "To" "domain", header :contains "From" "domain")
  {
    discard;
    stop;
  }
