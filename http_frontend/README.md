# http_frontend

* stream switching, ssl termination, rate limiting, proxying, static webserver using nginx
+ letsencrypt **host certificates** via **ALPN on https** port using acme.sh
+ pki management for easy **client certificates** support and administration using easy-rsa
+ **geoip2** databases for augumentation of location HEADER information for upstreams
+ **oauth2-proxy** support for **oidc authentification** of legacy upstreams using auth_request
+ extended **prometheus stats** using lua_nginx_prometheus
+ **configuration** using **pillar:nginx**, for details see defaults.jinja

+ Ssl Features
    + main domain can use cert from pillar (cert+key), letsencrypt or selfsigned
    + main domain and other virtual domains can have multiple letsencrypt SAN's
    + unknown domains or requests with an invalid sni will
        return a certificate for the domain "invalid" and return 404
    + manual virtual domains (where letsencrypt is not used) must be set up by
        copying certificates to disk structure

+ Proxy Features
    + pass request headers from downstream
    + set HOST, X-Real-IP, X-Forwarded-For, X-Forwarded-Host, X-Forwarded-Proto
    + defaults to proxy_http_version 1.1 , set "proxy_http_version 1.0;" if upstream does not speak HTTP 1.1

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

#### TODO: add custom build nginx

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
