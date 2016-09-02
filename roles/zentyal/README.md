
lightning:
  file.managed:
    - source: 'https://addons.mozilla.org/thunderbird/downloads/file/146488/lightning-1.2.3-tb+sm-windows.xpi?src=version-history'

sogo_integrator:
  file.managed:
    - source: salt://roles/sogo-zentyal/sogo-integrator-10.0.6-sogo.xpi

fix_mailfilter:
  cmd.run:
    - name: echo "DROP DATABASE spamassassin;" | mysql --defaults-file=/etc/mysql/debian.cnf; /usr/share/zentyal-mailfilter/create-spamassassin-db

generate_new_mail_config:
  cmd.run:
    - name: /etc/init.d/zentyal mail restart

update all and reroll:
  on target machine:

salt-call state.sls roles.zentyal; /etc/init.d/zentyal mail restart; /etc/init.d/postfix restart

notes:
# create mailboxes
# doveadm mailbox create public.incoming.2012 -u postmaster@domain
# doveadm mailbox create public.sent.2012 -u postmaster@domain
# create sieve of x@domain
## rule:[delete_from_to_same]
#if allof (not header :contains "To" "postmaster_public/incoming@domain", not header :contains "To" "postmaster_public/sent@domain", header :contains "To" "domain", header :contains "From" "domain")
#{
#        discard;
#        stop;
#}
