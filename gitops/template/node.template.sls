{% macro netcidr(cidr) %}{{ salt['network.convert_cidr'](cidr)['network'] }}{% endmacro %}
{% macro netmask(cidr) %}{{ salt['network.convert_cidr'](cidr)['netmask'] }}{% endmacro %}
{% macro cidr2ip(cidr) %}{{ cidr|regex_replace ('([^/]+)/.+', '\\1') }}{% endmacro %}
{% macro reverse_net(cidr) %}{{ salt['network.reverse_ip'](netcidr(cidr))|regex_replace('[^.]+\\.(.+)$', '\\1') }}{% endmacro %}
{% macro short_net(cidr) %}{{ cidr2ip(netcidr(cidr))|regex_replace('(.+)\\.[^.]+$', '\\1') }}{% endmacro %}

{%- macro mksnapshot(spaces, frequent=false, hourly=false, daily=false, weekly=false, monthly=false) %}
{{ ''|indent(spaces,True) ~ '"com.sun:auto-snapshot:frequent": "'~ frequent~ '"' }}
{{ ''|indent(spaces,True) ~ '"com.sun:auto-snapshot:hourly": "'~ hourly~ '"' }}
{{ ''|indent(spaces,True) ~ '"com.sun:auto-snapshot:daily": "'~ daily~ '"' }}
{{ ''|indent(spaces,True) ~ '"com.sun:auto-snapshot:weekly": "'~ weekly~ '"' }}
{{ ''|indent(spaces,True) ~ '"com.sun:auto-snapshot:monthly": "'~ monthly~ '"' }}
{%- endmacro %}

{% set project_basepath=grains['project_basepath'] %}

{%- set env_to_yaml= 'grep -v -e "^[[:space:]]*$" | grep -v "^#" | '+
    'sort | uniq | sed -r "s/([^=]+)=(.*)/\\1: \\2/g"' %}
{% import_text 'node.env' as node_input %}
{% set node = salt['cmd.run_stdout'](
    env_to_yaml, stdin=node_input, python_shell=True)|load_yaml %}

{% set def_route_device = salt['cmd.run_stdout']('ip -j route list default | sed -r \'s/.+dev":"([^"]+)".+/\\1/g\'', python_shell=true) %}
{% set def_route_ip = salt['cmd.run_stdout']('ip -j addr show '+ def_route_device+ ' | sed -r \'s/.+"inet","local":"([^"]+)",.+/\\1/g\'', python_shell=true) %}
{% set internal_cidr = '10.140.250.1/24' %}
{% set internal_name = 'resident' %}
{% set netplan = "" %}
{% set systemd_network = "" %}

{% set ssh_authorized_keys = "" %}
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
{% if salt['file.file_exists'](project_basepath+ '/config/systemd.network') %}
  {% import_text 'systemd.network' as systemd_network %}
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


{% load_yaml as network_internal %}
cidr: {{ internal_cidr }}
name: {{ internal_name }}
netcidr: {{ netcidr(internal_cidr) }}
netmask: {{ netmask(internal_cidr) }}
ip: {{ cidr2ip(internal_cidr) }}
reverse_net: {{ reverse_net(internal_cidr) }}
short_net: {{ short_net(internal_cidr) }}
{% endload %}

{% set config= {
  "basepath": project_basepath,
  "node": node,
  "network": {
      "internal": network_internal,
      "netplan": netplan,
      "systemd": systemd_network,
      "def_route_device": def_route_device,
      "def_route_ip": def_route_ip,
    },
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
