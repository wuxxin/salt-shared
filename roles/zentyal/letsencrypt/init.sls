/etc/dovecot/dovecot.conf:
ssl_cert =</etc/dovecot/private/dovecot.pem
ssl_key =</etc/dovecot/private/dovecot.pem

/etc/postfix/main.cf:
smtpd_tls_key_file  = /etc/postfix/sasl/postfix.pem
smtpd_tls_cert_file = /etc/postfix/sasl/postfix.pem

/etc/apache2/conf-available/100-zentyal-ocsmanager-ep3.at-ssl.conf:
SSLCertificateFile /etc/ocsmanager/ep3.at.pem
