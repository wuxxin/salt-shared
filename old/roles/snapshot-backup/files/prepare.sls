{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}
{% set hostname="backup" %}
{% set fqdn="backup.in.domain" %}

{{ hostname }}_{{ s.user }}_directories:
  file.directory:
    - name: {{ salt['user.info'](s.user)['home'] }}/{{ hostname }}
    - user: {{ s.user }}
    - group: libvirtd
    - dir_mode: 770
    - makedirs: True
    
{% for a in ['Vagrantfile', 'minion_id'] %}
{{ hostname }}_{{ s.user }}_{{ a }}:
  file.managed:
    - source: salt://{{ hostname }}/{{ a }}
    - name: {{ salt['user.info'](s.user)['home'] }}/{{ hostname }}/{{ a }}
    - user: {{ s.user }}
    - group: libvirtd
    - mode: 750
    - dir_mode: 770
    - makedirs: True
    - template: jinja
    - context:
      hostname: {{ hostname }}
      fqdn: {{ fqdn }}
    - require:
      - file: {{ hostname }}_{{ s.user }}_directories
{% endfor %}

{{ hostname }}_make_key:
  cmd.run:
    - cwd: {{ salt['user.info'](s.user)['home'] }}/{{ hostname }}
    - name: salt-key -y --gen-keys={{ fqdn }} && cp {{ fqdn }}.pub /etc/salt/pki/master/minions/{{ fqdn }} && chown {{ s.user }} {{ fqdn }}.*
    - unless: test -f {{ salt['user.info'](s.user)['home'] }}/{{ hostname }}/{{ fqdn }}.pem
