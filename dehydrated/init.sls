dehydrated_user:
  group.present:
    - name: dehydrated
  user.present:
    - name: dehydrated
    - gid: dehydrated
    - home: /usr/local/etc/dehydrated
    - shell: /bin/bash
    - remove_groups: False
    - groups:
      - www-data

/usr/local/bin/dehydrated:
  file.managed:
    - source: salt://dehydrated/dehydrated
    - mode: "0775"

{% for i in ['acme-challenge', 'certs'] %}
/usr/local/etc/dehydrated/{{ i }}:
  file.directory:
    - user: dehydrated
    - group: dehydrated
    - makedirs: true
{% endfor %}

/usr/local/etc/dehydrated/config:
  file.managed:
    - user: dehydrated
    - group: dehydrated
    - contents: |
        BASEDIR="/usr/local/etc/dehydrated"
        WELLKNOWN="/usr/local/etc/dehydrated/acme-challenge"
        {%- for i, d in salt['pillar.get']('letsencrypt').iteritems() %}
          {%- if i not in ['domains', 'enable', 'config'] %}
        {{ i|upper }}="{{ d }}"
          {%- endif %}
        {%- endfor %}

/usr/local/etc/dehydrated/domains.txt:
  file.managed:
    - user: dehydrated
    - group: dehydrated
    - contents: |
        {{ salt['pillar.get']('letsencrypt:domains', {})[0] }}{% for i in salt['pillar.get']('letsencrypt:domains', {}) %} {{ i }}{% endfor %}

  {% if salt['pillar.get']('letsencrypt:config:apache', false) %}
/etc/apache2/conf-available/10-wellknown-acme.conf:
  file.managed:
    - source: salt://dehydrated/apache.conf
    - makedirs: true

/etc/apache2/conf-enabled/10-wellknown-acme.conf:
  file.symlink:
    - target: /etc/apache2/conf-available/10-wellknown-acme.conf
    - makedirs: true

  {% endif %}

