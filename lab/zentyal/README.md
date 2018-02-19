# Zentyal 5.x Mail server

* !! Use rspamd instead of spamassassin

## additional pillar settings

look at pillar.template.sls

## Thunderbird

+ install lightning: https://addons.mozilla.org/de/thunderbird/addon/lightning/
+ install sogo connector or sogo integrator
  + https://sogo.nu/files/downloads/SOGo/Thunderbird/sogo-connector-31.0.5.xpi
  + https://sogo.nu/files/downloads/SOGo/Thunderbird/sogo-integrator-31.0.5-sogo-demo.xpi

## Toolbox

fix_mailfilter:
  cmd.run:
    - name: echo "DROP DATABASE spamassassin;" | mysql --defaults-file=/etc/mysql/debian.cnf; /usr/share/zentyal-mailfilter/create-spamassassin-db

generate_new_mail_config:
  cmd.run:
    - name: /etc/init.d/zentyal mail restart

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
