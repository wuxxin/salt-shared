# SSL-Config for apache, nginx, dovecot, postfix

## apache 2.4.18

### mods-available/ssl.conf
```
SSLProtocol             all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
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
ssl_protocols all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1;
ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';
ssl_prefer_server_ciphers on;
# OCSP Stapling, fetch OCSP records from URL in ssl_certificate and cache them
ssl_stapling on;
ssl_stapling_verify on;
```

## dovecot

```
# dovecot ssl setup
ssl = yes
ssl_cert =</app/etc/server.cert.pem
ssl_key =</app/etc/server.key.pem
# DH parameters length to use.
ssl_dh_parameters_length = 2048
ssl_dh = </app/etc/dhparam.pem
# SSL protocols to use
ssl_protocols = all -SSLv3 -SSLv2 -TLSv1
# SSL ciphers to use
ssl_cipher_list = ALL:!LOW:!SSLv2:!SSLv3:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!3DES:!PSK
# Prefer the server's order of ciphers over client's.
ssl_prefer_server_ciphers = yes
# SSL extra options. Currently supported options are:
#   no_compression - Disable compression.
ssl_options = no_compression
```

## postfix

```
smtpd_tls_eecdh_grade = strong
smtpd_tls_security_level = may
smtpd_tls_protocols = all -SSLv2 -SSLv3 -TLSv1
smtpd_tls_ciphers = medium
smtpd_tls_mandatory_protocols = all -SSLv2 -SSLv3 -TLSv1
smtpd_tls_mandatory_ciphers = high
smtpd_tls_mandatory_exclude_ciphers = aNULL, eNULL, EXPORT, DES, RC4, MD5, 3DES, PSK
smtpd_tls_received_header = yes
smtpd_tls_loglevel = 1

smtp_use_tls=yes
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache
smtp_tls_security_level = may
smtp_tls_protocols = all -SSLv2 -SSLv3 -TLSv1
smtp_tls_ciphers = medium
smtp_tls_mandatory_protocols = all -SSLv2 -SSLv3 -TLSv1
smtp_tls_mandatory_ciphers = high
smtp_tls_mandatory_exclude_ciphers = aNULL, eNULL, EXPORT, DES, RC4, MD5, 3DES, PSK
smtp_tls_loglevel = 1
```
