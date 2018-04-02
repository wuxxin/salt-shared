# SSL-Config for apache, nginx, dovecot, postfix

## apache 2.4.18

### mods-available/ssl.conf
```
SSLProtocol             TLSv1.2
SSLCipherSuite          ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256

SSLSessionTickets       off
SSLHonorCipherOrder     on
SSLCompression          off
SSLUseStapling          on
SSLStaplingResponderTimeout 5
SSLStaplingReturnResponderErrors off
SSLStaplingCache        shmcb:/var/run/ocsp(128000)
```

### sites-available/default-ssl.conf
```
SSLCertificateFile /app/etc/server.cert.dhparam.pem
SSLCertificateKeyFile /app/etc/server.key.pem
```

## nginx 1.10.3

``` 
ssl on;
ssl_certificate <% $zentyalconfdir %>ssl/ssl.pem;
ssl_certificate_key <% $zentyalconfdir %>ssl/ssl.pem;
ssl_dhparam /app/etc/dhparam.pem;
ssl_session_timeout 8h;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
# modern configuration. tweak to your needs.
ssl_protocols TLSv1.2;
ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';
ssl_prefer_server_ciphers on;
# OCSP Stapling, fetch OCSP records from URL in ssl_certificate and cache them
ssl_stapling on;
ssl_stapling_verify on;
```

## dovecot 2.2.22

```
# dovecot ssl setup
ssl = yes
ssl_cert = </etc/dovecot/private/dovecot.pem
ssl_key = </etc/dovecot/private/dovecot.pem
# DH parameters length to use.
ssl_dh_parameters_length = 2048
# XXX ssl_dh will be set in mail.postsetconf
#ssl_dh = </app/etc/dhparam.pem
# SSL protocols to use
ssl_protocols = TLSv1.2, TLSv1.1, !TLSv1, !SSLv3, !SSLv2
# SSL ciphers to use
ssl_cipher_list = ALL:!LOW:!SSLv2:!SSLv3:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!3DES:!PSK
# Prefer the server's order of ciphers over client's.
ssl_prefer_server_ciphers = yes
# SSL extra options. Currently supported options are:
#   no_compression - Disable compression.
ssl_options = no_compression
```

## postfix 3.1.0-3ubuntu0.3

```
# TLS/SSL
# enforce the server cipher preference
tls_preempt_cipherlist = yes

# TLS/SSL Incoming
smtpd_use_tls = yes
smtpd_tls_key_file  = <% $keyFile  %>
smtpd_tls_cert_file = <% $certFile %>
# dhparam takes >= 1024bit (eg.2048) dhparam file
# XXX smtpd_tls_dh1024 will be set in mail.postsetconf
#smtpd_tls_dh1024_param_file = /app/etc/dhparam.pem

smtpd_tls_eecdh_grade = strong
smtpd_tls_security_level = may
smtpd_tls_protocols = TLSv1.2, TLSv1.1, !TLSv1, !SSLv3, !SSLv2
smtpd_tls_ciphers = medium
smtpd_tls_exclude_ciphers = aNULL, eNULL, EXPORT, DES, RC4, MD5, 3DES, PSK
smtpd_tls_mandatory_protocols = TLSv1.2, !TLSv1.1, !TLSv1, !SSLv3, !SSLv2
smtpd_tls_mandatory_ciphers = high
smtpd_tls_mandatory_exclude_ciphers = aNULL, eNULL, EXPORT, DES, RC4, MD5, 3DES, PSK
smtpd_tls_received_header = yes
smtpd_tls_loglevel = 1

# TLS Outgoing
smtp_use_tls=yes
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache
smtp_tls_security_level = may
smtp_tls_protocols = TLSv1.2, TLSv1.1, !TLSv1, !SSLv3, !SSLv2
smtp_tls_ciphers = medium
smtp_tls_exclude_ciphers = aNULL, eNULL, EXPORT, DES, RC4, MD5, 3DES, PSK
smtp_tls_mandatory_protocols = TLSv1.2, !TLSv1.1, !TLSv1, !SSLv3, !SSLv2
smtp_tls_mandatory_ciphers = high
smtp_tls_mandatory_exclude_ciphers = aNULL, eNULL, EXPORT, DES, RC4, MD5, 3DES, PSK
smtp_tls_loglevel = 1

```
