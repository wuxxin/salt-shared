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

{{ settings.env_file }}:
  file.managed:
    - mode: "600"
    - contents: |
      src_user={{ settings.user }}
      src_url={{ settings.git.source }}
      src_branch={{ settings.git.branch }}
      src_dir={{ settings.src_dir }}

{{ settings.home_dir }}/.ssh:
  file.directory:
    - mode: "0600"
    - user: {{ settings.user }}
    - group: {{ settings.user }}

{% if settings.git.ssh_id %}
fixme reinstall ssh id
{{ settings.home_dir }}/.ssh/id_ed25519:
  file.blockreplace:
    - mode: "0600"
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - require:
      - file: {{ settings.home_dir }}/.ssh
    - contents: |
{{ settings.git.ssh_id|indent(8,True)}}
{% endif %}

{% if settings.git.ssh_known_hosts %}
{{ settings.home_dir }}/.ssh/known_hosts:
fixme reinstall ssh_kown hosts
{% endif %}

{% if settings.git.gpg_id %}

fixme reinstall gpg id
{% endif %}


{% for i in ['tags', 'flags', 'metrics', 'www' %}
{{ settings.var_dir }}/{{ i }}:
  file.directory:
    - user: {{ settings.user }}
    - mode: "0750"
{% endfor %}


{{ settings.var_dir }}/flags/no.automatic.reboot:
  file:
{% if settings.automatic_reboot %}
    - absent
{% else %}
    - present
{% endif %}
    - user: {{ settings.user }}

{{ salt['file.dirname'](settings.maintenance_target) }}:
  file.directory:
    - makedirs: true

/usr/local/lib/gitops-library.sh:
  file.managed:
    - source: salt://gitops/gitops-library.sh
    - template: jinja
    - defaults:
        settings: {{ settings }}

{% for i in ['execute-saltstack.sh', 'from-git.sh', 'gitops-update.sh'] %}
/usr/local/sbin/{{ i }}:
  file.managed:
    - source: salt://gitops/{{ i }}
    - mode: "0755"
    - template: jinja
    - defaults:
        settings: {{ settings }}
{% endfor %}

/etc/systemd/system/gitops-update.service:
  file.managed:
    - source: salt://gitops/gitops-update.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - onchanges_in:
      - cmd: systemd_reload
