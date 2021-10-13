# http_frontend (glue around nginx)

+ stream switching, ssl termination, rate limiting, proxying, static webserver using **nginx**

+ **configuration** using **pillar:nginx**, for details see [defaults.jinja](defaults.jinja)
+ Ssl certificates can use
  + Certs **from pillar**, **Acme**, be created by the **Local CA** or be **Selfsigned**
  + can have multiple virtual domains with **multiple SAN's** per domain
+ **ACME** host certificates via **ALPN on https** port or **DNS-01** using **`acme.sh`**
+ **Local CA** pki management** for **client certificates**, **host certificates** using **easy-rsa**
  + **optional** or **mandatory client certificates**
+ **unknown or invalid sni domains** will **return 404** and a **"hostname.invalid"** certificate
+ optional augumentation with **location HEADER variables** for upstreams via **Geoip2** databases
+ simple **ratelimit** global or per domain support
+ **Oauth2-proxy** support for **oidc authentification** of legacy upstreams using auth_request
+ extended **Prometheus Stats** using **lua_nginx_prometheus**
+ **Downstream http/https proxy** PROXY protocol support

### Defaults

configured http **Upstreams** defaults:
  + http_version: 1.1, headers: HOST, X-Real-IP, X-Forwarded-For, X-Forwarded-Host, X-Forwarded-Proto

### TODO

### Administration

#### local CA pki
+ Creates a client certificate, and send certificate via Email
  + `create-client-certificate.sh email@address cert_name [--days daysvalid] [--san add-san-values]`
+ revoke an existing certificate
  + `revoke-certificate.sh cert_name --yes`
+ create a host certificate using the local CA
  + `create-host-certificate.sh [--days daysvalid] domain [domains*]`

#### Hooks
 commands configured in ssl.host.on_renew are called with
  + `$0 DOMAIN KEYFILE CERTFILE FULLCHAINFILE`

### example pillar

+ for details see [defaults.jinja](defaults.jinja)

```yaml
listen_ip:
  - default-route-ip
listen_service:
  - https
server_name: hostname.something another.something
virtual_names:
  - name: multi.domain other.san.name another.name.san
  - name: another.domain still.another.domain
    acme:
      enabled: false
  - name: name.domain *.name.domain
    acme:
      challenge: dns_knot
      env:
        KNOT_SERVER: "dns.example.com"
        KNOT_KEY: "a-long-secret-key"
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
  - name: k3s
    server: "10.88.0.1:8000"
location:
  - source: /hooks/
    target: proxy_pass http://webhooks
  - source: /
    target: root /var/www/main.domain/
host:
  - name: another.domain yet.another.domain
    client_cert_mandatory: true
    location:
      - source: /
        target: root /var/www/another.domain/
  - name: *.name.domain
    target: proxy_pass http://k3s
```
