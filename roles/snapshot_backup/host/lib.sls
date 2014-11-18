
{% macro create_backup_vm(settings) %}

template_dir:
  file.directory:
    - name: {{ settings.target }}/salt/key
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - makedirs: true

{% for a in ('Vagrantfile',) %}
backup_vm-copy-{{ a }}:
  file.managed:
    - source: "salt://roles/snapshot_backup/files/{{ a }}"
    - name: {{ settings.target }}/{{ a }}
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - mode: 700
    - template: jinja
    - context:
        target: {{ settings.target }}
        hostname: {{ settings.hostname|d(" ") }}
    - require:
      - file: template_dir
    - require_in:
      - cmd: generate_vm
{% endfor %}

generate_and_accept_minion_key:
  cmd.run:
    - cwd:  {{ settings.target }}/salt/key
    - name: "salt-key -y --gen-keys={{ hostname }} && cp {{ hostname }}.pub /etc/salt/pki/master/minions/{{ hostname }}"
    - unless: test -f /etc/salt/pki/master/minions/{{ hostname }}
    - require:
      - file: template_dir
    - require_in:
      - cmd: generate_vm

generate_vm:
  cmd.run:
    - cwd: {{ settings.target }}
    - user: {{ settings.user }}
    - name: vagrant up

move_vm_to_resident:
  cmd.run:
    - name: false
    - require:
      - cmd: generate_vm

set_autostart_backup_vm:
  module.run:
    - name: virt.set_autostart
    - m_name: {{ settings.hostname }}
    - require:
      - cmd: move_vm_to_resident

{% endmacro %}

{% macro start_backup_vm(hostname) %}

start_backup_vm:
  module.run:
    - name: virt.start
    - m_name: {{ hostname }}

{% endmacro %}
