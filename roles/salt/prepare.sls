include:
  - git-crypt

{% from "roles/salt/defaults.jinja" import settings as salt_settings with context %}
{% from "roles/salt/lib.sls" import saltmaster_make with context %}
{% from "roles/imgbuilder/preseed/defaults.jinja" import defaults as ps_def with context %}

{% load_yaml as update %}
salt:
  master_d:
    experimental:
      state_aggregate: True
{% endload %}
{{ do ps_def.update(update) }}

{{ saltmaster_make(salt_settings, ps_def.diskpassword_receiver_id, ps_def.diskpassword_receiver_key,
  ps_def.target, "/srv", ps_def.hostname, ps_def.domainname, ps_def.custom_ssh_identity, ps_def.netcfg) }}

