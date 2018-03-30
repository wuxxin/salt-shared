{% from "roles/imgbuilder/preseed/defaults.jinja" import defaults as settings with context %}

{% load_yaml as updates %}
custom_files:
  '/.ssh/authorized_keys': 'salt://roles/imgbuilder/preseed/files/vagrant.pub'
  '/watch': 'salt://roles/imgbuilder/preseed/files/watch'
default_preseed: 'preseed-custom-console.cfg'
{% endload %}

{#
  '/reboot.seconds': 'salt://roles/imgbuilder/preseed/files/reboot.seconds'

cmdline: 'DEBCONF_DEBUG=1 ro hostname=testing priority=critical debconf/frontend=noninteractive'
#}

{% from 'roles/imgbuilder/preseed/lib.sls' import preseed_make with context %}
{{ preseed_make(settings) }}

{% from 'roles/imgbuilder/preseed/iso.sls' import mk_install_iso with context %}
{{ mk_install_iso(settings) }}

