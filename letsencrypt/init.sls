{% if salt['pillar.get']('letsencrypt:enabled', false) %}

/usr/local/bin/letsencrypt.sh:
  file.managed:
    - source: salt://letsencrypt/letsencrypt.sh
    - mode: "0775"

{% for i in ['acme-challenge', 'certs'] %}
/usr/local/etc/letsencrypt.sh/{{ i }}:
  file.directory:
    - makedirs: true
{% endfor %}

/usr/local/etc/letsencrypt.sh/config:
  file.managed:
    - contents: |
        BASEDIR="/usr/local/etc/letsencrypt.sh"
        WELLKNOWN="/usr/local/etc/letsencrypt.sh/acme-challenge"
        {%- for i, d in salt['pillar.get']('letsencrypt').iteritems() %}
          {%- if i not in ['domains', 'enable', 'config'] %}
        {{ i|upper }}="{{ d }}"
          {%- endif %}
        {%- endfor %}

/usr/local/etc/letsencrypt.sh/domains.txt:
  file.managed:
    - contents: |
        {%- for i in salt['pillar.get']('letsencrypt:domains', {}) %}
        {{ i }}
        {%- endfor %}

  {% if salt['pillar.get']('letsencrypt:config:apache', true) %}
/etc/apache2/conf-available/10-wellknown-acme.conf:
  file.managed:
    - source: salt://letsencrypt/apache.conf
    - makedirs: true

/etc/apache2/conf-enabled/10-wellknown-acme.conf:
  file.symlink:
    - target: /etc/apache2/conf-available/10-wellknown-acme.conf
    - makedirs: true

wellknown-acme-apache-reload:
  service.running:
    - name: apache2
    - enable: True
    - watch:
      - file: /etc/apache2/conf-enabled/10-wellknown-acme.conf

  {% endif %}


{% endif %}
