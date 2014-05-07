
fix_mailfilter:
  cmd.run:
    - name: echo "DROP DATABASE spamassassin;" | mysql --defaults-file=/etc/mysql/debian.cnf; /usr/share/zentyal-mailfilter/create-spamassassin-db

generate_new_mail_config:
  cmd.run:
    - name: /etc/init.d/zentyal mail restart

update all and reroll:
  on target machine:

salt-call state.sls roles.zentyal; /etc/init.d/zentyal mail restart; /etc/init.d/postfix restart