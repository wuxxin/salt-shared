{% set project_basepath=grains['project_basepath'] %}

{%- set env_to_yaml= 'grep -v -e "^[[:space:]]*$" | grep -v "^#" | '+
    'sort | uniq | sed -r "s/([^=]+)=(.*)/\\1: \\2/g"' %}
{% import_text 'node.env' as node_input %}
{% set node = salt['cmd.run_stdout'](
    env_to_yaml, stdin=node_input, python_shell=True)|load_yaml %}

{% set ssh_authorized_keys = "" %}
{% set netplan = "" %}
{% set gitops_ssh_secret = "" %}
{% set gitops_ssh_public = "" %}
{% set gitops_gpg_secret = "" %}
{% set gitops_gpg_public = "" %}
{% set gitops_known_hosts = "" %}

{% if salt['file.file_exists'](project_basepath+ '/config/authorized_keys') %}
  {% import_text 'authorized_keys' as ssh_authorized_keys %}
{% endif %}
{% if salt['file.file_exists'](project_basepath+ '/config/netplan.yaml') %}
  {% import_text 'netplan.yaml' as netplan %}
{% endif %}
{% if salt['file.file_exists'](project_basepath+ '/config/gitops.id_ed25519') %}
  {% import_text 'gitops.id_ed25519' as gitops_ssh_secret %}
{% endif %}
{% if salt['file.file_exists'](project_basepath+ '/config/gitops.id_ed25519.pub') %}
  {% import_text 'gitops.id_ed25519.pub' as gitops_ssh_public %}
{% endif %}
{% if salt['file.file_exists'](project_basepath+ '/config/gitops@node-secret-key.gpg') %}
  {% import_text 'gitops@node-secret-key.gpg' as gitops_gpg_secret %}
{% endif %}
{% if salt['file.file_exists'](project_basepath+ '/config/gitops@node-public-key.gpg') %}
  {% import_text 'gitops@node-public-key.gpg' as gitops_gpg_public %}
{% endif %}
{% if salt['file.file_exists'](project_basepath+ '/config/gitops.known_hosts') %}
  {% import_text 'gitops.known_hosts' as gitops_known_hosts %}
{% endif %}

{% set gitops_user = node.gitops_user|d(node.firstuser) %}
{% set gitops_target = node.gitops_target|d(
  salt['cmd.run']('getent passwd '+ gitops_user+ ' | cut -d: -f6', python_shell=True)) %}

{% set config= {
  "basepath": project_basepath,
  "node": node,
  "netplan": netplan,
  "ssh_authorized_keys": ssh_authorized_keys,
  "gitops_ssh_secret": gitops_ssh_secret,
  "gitops_ssh_public": gitops_ssh_public,
  "gitops_gpg_secret": gitops_gpg_secret,
  "gitops_gpg_public": gitops_gpg_public,
  "gitops_known_hosts": gitops_known_hosts,
  "gitops_user": gitops_user,
  "gitops_target": gitops_target,
  }
%}
