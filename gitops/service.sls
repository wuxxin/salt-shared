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

gitops-library.sh:
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
      - file: gitops-library.sh
    - require_in:
      - file: /etc/systemd/system/gitops-update.service
{% endfor %}

{% for i in ['tags', 'flags', 'metrics', 'www' %}
{{ settings.var_dir }}/{{ i }}:
  file.directory:
    - user: {{ settings.user }}
    - makedirs: true
    - mode: "0750"
    - require_in:
      - file: /etc/systemd/system/gitops-update.service
{% endfor %}

{{ salt['file.dirname'](settings.maintenance_target) }}:
  file.directory:
    - makedirs: true
    - user: {{ settings.user }}
    - group: {{ settings.user }}

{% for i in ['.ssh', '.gnupg'] %}
{{ settings.home_dir }}/{{ i }}:
  file.directory:
    - mode: "0600"
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - require_in:
      - file: /etc/systemd/system/gitops-update.service
{% endif %}

{{ settings.var_dir }}/flags/no.automatic.reboot:
  file:
{% if settings.automatic_reboot %}
    - absent
{% else %}
    - present
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
    - require:
      - file: {{ settings.home_dir }}/.ssh
prepend_id_ed25519:
  file.prepend:
    - name: {{ settings.home_dir }}/.ssh/id_ed25519
    - require:
      - file: create_id_ed25519
    - contents: |
{{ settings.git.ssh_id|indent(8,True)}}
{% endif %}

{% if settings.git.ssh_known_hosts %}
create_known_hosts:
  file.managed:
    - name: {{ settings.home_dir }}/.ssh/known_hosts
    - mode: "0600"
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - require:
      - file: {{ settings.home_dir }}/.ssh
prepend_known_hosts:
  file.prepend:
    - name: {{ settings.home_dir }}/.ssh/known_hosts
    - require:
      - file: create_known_hosts
    - contents: |
{{ settings.git.ssh_known_hosts|indent(8,True)}}
{% endif %}

{% if settings.git.gpg_id %}
  {% set gpg_fullname = salt['file.basename'](settings.src_dir)+ ' <gitops@node>' %}
  {% set get_fingerprint = 'gosu '+ settings.user+
    ' gpg --batch --yes --list-key --with-colons '+ '"'+ gpg_fullname+ '"'+
    ' |  grep "^fpr" | head -1 | sed -r "s/^.+:([^:]+):$/\\1/g"' %}
add_gpg_id:
  cmd.run:
    - name: echo "{{ settings.git.gpg_id }}" | gosu {{ settings.user }} gpg --batch --yes --import
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

gitops-update:
  file.managed:
    - name: /etc/systemd/system/gitops-update.service
    - source: salt://gitops/gitops-update.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
  service.running:
    - enable: true
    - require:
      - file: gitops-update
    - onchanges:
      - file: /etc/systemd/system/gitops-update.service
