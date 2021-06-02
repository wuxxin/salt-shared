# http_frontend (glue around nginx)

+ stream switching, ssl termination, rate limiting, proxying, static webserver using **nginx**

+ letsencrypt **host certificates** via **ALPN on https** port or **DNS-01** using **`acme.sh`**
+ **pki management** for easy **client certificates** support and administration using **easy-rsa**
+ **geoip2** databases for augumentation of location HEADER information for upstreams
+ **oauth2-proxy** support for **oidc authentification** of legacy upstreams using auth_request
+ extended **prometheus stats** using **lua_nginx_prometheus**
+ **configuration** using **pillar:nginx**, for details see [defaults.jinja](defaults.jinja)
+ Ssl domains certificates can use **certs from pillar** (cert+key), **letsencrypt** or be **selfsigned**
+ multiple virtual domains with **multiple SAN's** per domain
+ **unknown domains or invalid sni** requests will **return 404** and a **"hostname.invalid"** certificate
+ **Downstream http/https proxy** PROXY protocol support
+ configurable **set_real_ip_from** addresses of trusted downstream proxies
+ http **Upstreams**: http_version: 1.1, headers: HOST, X-Real-IP, X-Forwarded-For, X-Forwarded-Host, X-Forwarded-Proto

### Administration

+ create-client-certificate.sh
    user-email@address.domain cert_name [--days daysvalid] [--san additional-san-values]

    + Creates a client certificate, and send certificate via Email

+ revoke-client-certificate.sh cert_name --yes

    + revokes an existing client certificate

+ cert-renew-hook.sh DOMAIN KEYFILE CERTFILE FULLCHAINFILE

+ create-selfsigned-host-cert.sh
    -k <keyfile_target> -c <certfile_target> domain [additional-domain]*

### TODO

+ make letsencrypt generation honour vhost:letsencrypt:false in addition to settings.letsencrypt
+ make selfsigned virtual hosts certs with right name
+ make letsencrypt of vhosts honour additional SANS
+ make ssl, letsencrypt and pki use cert_user

+ FIXME: make letsencrypt use dns as alternative
+ FIXME: make letsencrypt * certificates

### example, for details see [defaults.jinja](defaults.jinja)

```yaml
listen_ip:
  - default-route-ip
listen_service:
  - https
server_name: hostname.something another.something
virtual_names:
  - name: multi.domain other.san.name another.name.san
  - name: another.domain still.another.domain
    letsencrypt:
      enabled: false
  - name: *.name.domain
    letsencrypt:
      challenge: dns_knot
      env:
        KNOT_SERVER: "dns.example.com"
        KNOT_KEY: ""
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

### snippets

```
# subjectAltName=IP:192.168.7.1
# subjectAltName=IP:13::17
# subjectAltName=DNS:some.other.address
# subjectAltName=email:copy,email:my@other.address,URI:http://my.url.here/
# subjectAltName=email:my@other.address,RID:1.2.3.4
# subjectAltName=otherName:1.2.3.4;UTF8:some other identifier
#
# subjectAltName=dirName:dir_sect
#
# [dir_sect]
# C=UK
# O=My Organization
# OU=My Unit
# CN=My Name
```

```
  {% if settings.nginx_custom_build %}
    {%- set patch_list= ['ipscrub.patch', ] %}
    {%- set patch_dir='/usr/local/src/nginx-custom-patches' %}
    {%- set patches_string= patch_dir+ '/'+ patch_list|join(' '+ patch_dir+ '/') %}
    {%- set custom_archive= '/usr/local/lib/nginx-custom-archive' %}

    {% for p in patch_list %}
add-patch-{{ p }}:
  file.managed:
    - source: salt://http_frontend/nginx/{{ p }}
    - name: {{ patch_dir }}/{{ p }}
    - makedirs: true
    - require_in:
      - cmd: nginx-custom-build
    {% endfor %}

nginx-custom-build:
  cmd.run:
    - name: /usr/local/sbin/build-from-lp.sh {{ custom_archive }} "ipscrub" {{ patches_string }}
    - require:
      - sls: ubuntu.build-from-lp

nginx-custom-repo:
  pkgrepo.managed:
    - name: 'deb [ trusted=yes ] file:{{ custom_archive }} ./'
    - file: /etc/apt/sources.list.d/local-nginx-custom.list
    - require_in:
      - pkg: nginx
    - require:
      - cmd: nginx-custom-build
  {% endif %}
```
