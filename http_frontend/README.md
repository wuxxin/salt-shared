# http_frontend

uses nginx as frontend webserver, acme.sh via ALPN for letsencrypt service, easy-rsa for pki management.

### pillar
see defaults.jinja

#### ssl settings
+ one main domain with multiple SAN's
+ other isolated domains with one name per cert
+ main domain can use cert from pillar data (cert+key), letsencrypt, or selfsigned
+ isolated subdomains must be letsencrypt or somehow created and moved to the target dir

#### example

```yaml
user: {{ user }}
listen_ip:
  - default-route-ip
domain: hostname if empty
allowed_hosts: [hostname if empty]
letsencrypt: default true
client_cert_verify: default false, true will make optional client certificate verification
client_cert_mandatory: default false, true will make mandatory client certificate verification
cert_dir: {{ user_home }}/ssl
upstream: # [] # list of {name, server}
  - name: webhooks
    server: "127.0.0.1:5555"
location:
  - source: /hooks/
    target: proxy_pass http://webhooks
  - source: /
    target: root /var/www/main.domain/
host:
  - domain: another.domain
    client_cert_verify: true
    location:
      - source: /
        target: root /var/www/another.domain/
```
