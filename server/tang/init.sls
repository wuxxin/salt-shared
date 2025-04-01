

haproxy:
  pkg:
    - installed

tangd:
  pkg:
    - installed


haproxy.conf:
  file.managed:
  - contents: |     
      global
        maxconn 2000
        log /dev/log local0
        chroot /var/lib/haproxy
        user haproxy
        group haproxy
        daemon

      defaults
        log global
        mode http
        timeout connect 5000ms
        timeout client 50000ms
        timeout server 50000ms

      frontend https-in
        bind *:8443 ssl crt /etc/ssl/certs/mycert.pem verify required ca-file /etc/ssl/certs/root-ca.pem
        tcp-request inspect-delay 5s
        tcp-request content accept if { req.ssl_hello_type 1 }
        acl client_alt_name_check ssl_c_s_dn(cn) -m reg -i tang
        http-request deny unless client_alt_name_check
        default_backend app-backend

      backend app-backend
        mode http
        server app-server 127.0.0.1:8812
        http-request set-header X-Forwarded-For %[src]
