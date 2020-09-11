# http_frontend

+ ssl termination, stream switching, rate limiting, proxing, static webserver using nginx
+ **letsencrypt certificates** via **ALPN on https** port using acme.sh
+ extended **prometheus stats** using lua_nginx_prometheus
+ pki management for easy **client certificates** support and administration using easy-rsa
+ **geoip2** databases for augumentation of location HEADER information for upstreams
+ **oauth2-proxy** support for **oidc authentification** of legacy upstreams using auth_request
+ **configuration** using **pillar:nginx**, for details see defaults.jinja

+ ssl Features
    + main domain can use cert from pillar data (cert+key), letsencrypt, or selfsigned
    + main domain and other virtual domains can have multiple letsencrypt SAN's
    + unknown domains or requests with an invalid sni will return a certificate for the domain "invalid" and return 404
    + manual virtual domains (where letsencrypt is not used) must be set up by copying certificates to disk structure

#### example, for details see defaults.jinja

```yaml
user: {{ user }}
listen_ip:
  - default-route-ip
domain: hostname.if.empty
allowed_hosts:
  - hostname.if.empty
  - localhost.if.empty
virtual_hosts:
  - another.domain
  - multi.domain other.san.name another.name.san
letsencrypt: default true
client_cert_verify: default false, true will make optional client certificate verification
client_cert_mandatory: default false, true will make mandatory client certificate verification
cert_dir: {{ user_home }}/ssl
geoip:
  enabled: true
ratelimit:
  enabled: true
  global: true
metrics:
  prometheus: true
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
