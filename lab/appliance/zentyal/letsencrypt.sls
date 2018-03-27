include:
  - dehydrated
  - .base

{% from "dehydrated/defaults.jinja" import settings, letsencrypt with context %}

{% set firstdomain = letsencrypt.domains[0].split(' ')[0] %}

zentyal-dehydrated-hook:
  file.managed:
    - name: /usr/local/etc/dehydrated/zentyal-dehydrated-hook.sh
    - source: salt://lab/appliance/zentyal/files/zentyal-dehydrated-hook.sh
    - mode: "0755"
    - require:
      - sls: dehydrated
      - sls: .base

/app/etc/hooks/appliance-update/check/zentyal-letsencrypt.sh:
  file.managed:
    - source: salt://lab/appliance/zentyal/files/check-zentyal-letsencrypt.sh
    - makedirs: true
    - mode: "0755"

/app/etc/hooks/appliance-update/update/zentyal-letsencrypt:
  file.managed:
    - source: salt://lab/appliance/zentyal/files/update-zentyal-letsencrypt.sh
    - makedirs: true
    - mode: "0755"

{% for i in ['deploy-cert-as-root.sh', 'unchanged-cert-as-root.sh'] %}
/usr/local/sbin/{{ i }}:
  file.managed:
    - mode: "0755"
    - source: salt://lab/appliance/zentyal/files/{{ i }}
{% endfor %}

/etc/sudoers.d/dehydrated_newcert:
  file.managed:
    - makedirs: True
    - mode: "0440"
    - contents: |
        dehydrated ALL=(ALL) NOPASSWD: /usr/local/sbin/deploy-cert-as-root.sh
        dehydrated ALL=(ALL) NOPASSWD: /usr/local/sbin/unchanged-cert-as-root.sh

zentyal-apache-reload:
  service.running:
    - name: apache2
    - enable: True
    - watch:
      - file: /etc/apache2/conf-available/10-wellknown-acme.conf
    - require:
      - sls: dehydrated
      - pkg: zentyal

dhparam-creation:
  cmd.run:
    - name: gosu app openssl dhparam 2048 -out /app/etc/dhparam.pem
    - unless: test -e /app/etc/dhparam.pem && test "$(stat -L -c %s /app/etc/dhparam.pem)" -ge 224

initial-cert-creation:
  cmd.run:
    - name: /usr/local/bin/dehydrated -c
    - runas: dehydrated
    - unless: test -e /usr/local/etc/dehydrated/certs/{{ firstdomain }}/fullchain.pem
    - require:
      - file: zentyal-dehydrated-hook
      - service: zentyal-apache-reload
      - cmd: dhparam-creation
      - sls: dehydrated
      
