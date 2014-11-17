{% from "roles/imgbuilder/preseed/defaults.jinja" import defaults as ps_set with context %}

{% load_yaml as updates %}
{% set hostname= "backup_vm" %}
target: '/mnt/images/templates/imgbuilder/{{ hostname }}'
hostname: {{ hostname }}
{% endload %}
{% do ps_set.update(updates) %}

{% macro create_backup_vm(ps_set) %}

template_dir:
  file.directory:
    - name: {{ ps_set.target }}/salt/key
    - user: {{ ps_set.user }}
    - group: {{ ps_set.user }}
    - makedirs: true

{% for a in ('Vagrantfile',) %}
backup_vm-copy-{{ a }}:
  file.managed:
    - source: "salt://roles/snapshot_backup/files/{{ a }}"
    - name: {{ ps_set.target }}/{{ a }}
    - user: {{ ps_set.user }}
    - group: {{ ps_set.user }}
    - mode: 700
    - template: jinja
    - context:
        target: {{ ps_set.target }}
        hostname: {{ ps_set.hostname|d(" ") }}
    - require:
      - file: template_dir
{% endfor %}

generate_and_accept_minion_key:
  cmd.run:
    - cwd:  {{ ps_set.target }}/salt/key
    - name: "salt-key -y --gen-keys={{ hostname }} && cp {{ hostname }}.pub /etc/salt/pki/master/minions/{{ hostname}}"
    - unless: test -f /etc/salt/pki/master/minions/{{ hostname }}
    - require:
      - file: template_dir

{% endmacro %}
