{% from "gitops/defaults.jinja" import settings with context %}
include:
  - tools.sentry

gitop-requisites:
  pkg.installed:
    - pkgs:
      - curl
      - gosu
      - git
      - gnupg
      - git-crypt

/usr/local/lib/gitops-library.sh:
  file.managed:
    - source: salt://gitops/gitops-library.sh
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - require:
      - pkg: gitop-requisites
      - sls: tools.sentry
    - require_in:
      - file: /etc/systemd/system/gitops-update.service

{% for i in ['execute-saltstack.sh', 'from-git.sh', 'gitops-update.sh'] %}
/usr/local/sbin/{{ i }}:
  file.managed:
    - source: salt://gitops/{{ i }}
    - mode: "0755"
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - require:
      - pkg: gitop-requisites
      - file: /usr/local/lib/gitops-library.sh
    - require_in:
      - file: /etc/systemd/system/gitops-update.service
{% endfor %}

create_var_dir:
  file.directory:
    - name: {{ settings.var_dir }}
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - mode: "0755"
    - require_in:
      - file: /etc/systemd/system/gitops-update.service

{% for i in ['tags', 'flags', 'metrics'] %}
{{ settings.var_dir }}/{{ i }}:
  file.directory:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - mode: "0750"
    - require:
      - file: create_var_dir
    - require_in:
      - file: /etc/systemd/system/gitops-update.service
{% endfor %}

create_gitops_maintenance_template:
  file.managed:
    - source: salt://gitops/template/maintenance.template.html
    - name: {{ settings.maintenance_template }}
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - require_in:
      - file: /etc/systemd/system/gitops-update.service

create_gitops_maintenance_target_dir:
  file.directory:
    - name: {{ salt['file.dirname'](settings.maintenance_target) }}
    - makedirs: true
    - mode: "0755"
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - require_in:
      - file: /etc/systemd/system/gitops-update.service

{% for i in ['.ssh', '.gnupg'] %}
{{ settings.home_dir }}/{{ i }}:
  file.directory:
    - mode: "0700"
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - require_in:
      - file: /etc/systemd/system/gitops-update.service
{% endfor %}

{{ settings.var_dir }}/flags/reboot.automatic.disable:
  file:
{% if settings.update_automatic_reboot %}
    - absent
{% else %}
    - managed
    - contents: ""
{% endif %}
    - user: {{ settings.user }}
    - require_in:
      - file: /etc/systemd/system/gitops-update.service

{{ settings.env_file }}:
  file.managed:
    - mode: "600"
    - makedirs: true
    - contents: |
        src_user={{ settings.user }}
        src_url={{ settings.git.source }}
        src_branch={{ settings.git.branch }}
        src_dir={{ settings.src_dir }}

{% if settings.git.ssh_id %}
create_id_ed25519:
  file.managed:
    - name: {{ settings.home_dir }}/.ssh/id_ed25519
    - mode: "0600"
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - replace: false
    - require:
      - file: {{ settings.home_dir }}/.ssh
prepend_id_ed25519:
  file.prepend:
    - name: {{ settings.home_dir }}/.ssh/id_ed25519
    - require:
      - file: create_id_ed25519
    - text: |
{{ settings.git.ssh_id|indent(8,True)}}
{% endif %}

{% if settings.git.ssh_known_hosts %}
create_known_hosts:
  file.managed:
    - name: {{ settings.home_dir }}/.ssh/known_hosts
    - mode: "0600"
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - replace: false
    - require:
      - file: {{ settings.home_dir }}/.ssh
prepend_known_hosts:
  file.prepend:
    - name: {{ settings.home_dir }}/.ssh/known_hosts
    - require:
      - file: create_known_hosts
    - text: |
{{ settings.git.ssh_known_hosts|indent(8,True)}}
{% endif %}

{% if settings.git.gpg_id %}
  {% set gpg_fullname = salt['file.basename'](settings.src_dir)+ ' <gitops@node>' %}
  {% set get_fingerprint = 'gosu '+ settings.user+
    ' gpg --batch --yes --list-key --with-colons '+ '"'+ gpg_fullname+ '"'+
    ' |  grep "^fpr" | head -1 | sed -r "s/^.+:([^:]+):$/\\1/g"' %}
add_gpg_id:
  cmd.run:
    - name: echo "$gpgid" | gosu {{ settings.user }} gpg --batch --yes --import
    - env:
      - gpgid: |
{{ settings.git.gpg_id|indent(12, True) }}
    - onlyif: test "$({{ get_fingerprint }})" = ""
    - require:
      - file: {{ settings.home_dir }}/.gnupg
trust_gpg_id:
  cmd.run:
    - name: echo "$({{ get_fingerprint }}):5:" | gosu {{ settings.user }} --batch --yes --import-ownertrust
    - onchanges:
      - cmd: add_gpg_id
    - require:
      - cmd: add_gpg_id
{% endif %}

/etc/systemd/system/gitops-service-failed@.service:
  file.managed:
    - source: salt://gitops/gitops-service-failed@.service
    - template: jinja
    - defaults:
      settings: {{ settings }}

{% for service in settings.onfailure_service %}
/etc/systemd/system/{{ service }}.service.d/onfailure.conf:
  file.managed:
    - makedirs: true
    - contents: |
        [Unit]
        OnFailure=gitops-service-failed@%n.service
    - require:
      - file: /etc/systemd/system/gitops-service-failed@.service
    - onchanges_in:
      - cmd: gitops-update
{% endfor %}

gitops-update:
  file.managed:
    - name: /etc/systemd/system/gitops-update.service
    - source: salt://gitops/gitops-update.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: gitops-update
  service.enabled:
    - watch:
      - file: gitops-update
    - require:
      - cmd: gitops-update
