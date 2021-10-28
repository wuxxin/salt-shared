# http_frontend (glue around nginx)

stream switching, ssl termination, rate limiting, proxying, static frontend webserver using **nginx**.


+ **configuration** is done in **pillar:http_frontend**, for details see [defaults.jinja](defaults.jinja)
+ **automatic SSL certificates** management for server_name and virtual_names
  + Certs can be from **pillar**, issued by **ACME**, be created by the **Local CA** or be **Selfsigned**
  + Certs can have multiple virtual domains with **multiple SAN's** per domain
  + **unknown or invalid SNI domains** will **return 404** and a **"hostname.invalid"** certificate
  + **ACME** creates certificates via **ALPN on https port** or **DNS-01** using **`acme.sh`**
  + **Local CA** pki management for **client certificates**, **host certificates** using **`easy-rsa`**
  + **optional** or **mandatory client certificates**
  + **configurable hooks** on certificate updates
+ **Oauth2-proxy** support for **oidc authentification** of legacy upstreams using auth_request
+ optional augumentation of **geo location HEADER variables** for upstreams via **Geoip2** databases
+ optional simple **ratelimit** globally or per domain
+ optional extended **Prometheus Stats** using **`lua_nginx_prometheus`**
+ Downstream http/https proxy via **PROXY protocol**
+ customizable **maintenance page** and http status **500,502,503,504 error pages**

### Usage

+ configured http **Upstreams** defaults
  + http_version: 1.1
  + headers: HOST, X-Real-IP, X-Forwarded-For, X-Forwarded-Host, X-Forwarded-Proto

+ to safely upgrade a location to websocket use
```
proxy_set_header Upgrade $safe_http_upgrade;
proxy_set_header Connection $safe_connection_upgrade;
```

+ mainenance support is enabled on the host for location "/",
  to also enable in an vhost, use the following inside location:
    +  `if (-f {{ settings.error.target_maintenance }}) { return 590; }`

### Administration

#### local CA
+ the local CA ist automatically created on first usage
+ Create a client certificate and send certificate via Email
  + `create-client-certificate.sh [--days <number>] [--user <user.email@address.domain>] <cert_name> [--san <san-values>]`
+ Create an additional host certificate using the local CA
  + `create-host-certificate.sh [--days <days>] <domain> [<domains>*]`
+ revoke an existing certificate
  + `revoke-certificate.sh cert_name --yes`

#### selfsigned Certificate
+ create an additional self signed certificate
  + `create-selfsigned-host-cert.sh [--days <days>] -k <keyfile> -c <certfile> <domain> [<domains>*]`

### Example Pillar

+ for details see [defaults.jinja](defaults.jinja)

```yaml
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
ssl:
  local_ca:
    organization: "Super Organization"
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

### Notes

+ Installing a root/CA Certificate
```
Given a CA certificate file foo.crt, follow these steps to install it on Ubuntu:
    Create a directory for extra CA certificates in /usr/share/ca-certificates:
     sudo mkdir /usr/local/share/ca-certificates/extra
    Copy the CA .crt file to this directory:
     sudo cp foo.crt /usr/local/share/ca-certificates/extra/foo.crt
    Let Ubuntu add the .crt file's path relative to /usr/local/share/ca-certificates to /etc/ca-certificates.conf:
     sudo dpkg-reconfigure ca-certificates
To do this non-interactively, run:
    sudo update-ca-certificates
In case of a .pem file on Ubuntu, it must first be converted to a .crt file:
openssl x509 -in foo.pem -inform PEM -out foo.crt
Or a .cer file can be converted to a .crt file:
openssl x509 -inform DER -in foo.cer -out foo.crt
```
