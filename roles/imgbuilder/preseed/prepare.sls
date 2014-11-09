{% from "roles/imgbuilder/defaults.jinja" import settings as base_settings with context %}
{% from "roles/imgbuilder/preseed/defaults.jinja" import defaults as settings with context %}

{% do settings.update({
  'custom_files':(
    ('/.ssh/authorized_keys', 'salt://roles/imgbuilder/preseed/files/vagrant.pub'),
    ('/watch', 'salt://roles/imgbuilder/preseed/files/watch')
  ),
  'default_preseed': 'preseed-custom-console.cfg',
}) %}

{#     ('/reboot.seconds', 'salt://roles/imgbuilder/preseed/files/reboot.seconds'),
  'cmdline': 'DEBCONF_DEBUG=5 ro hostname=testing priority=critical debconf/frontend=noninteractive'

#}

{% from 'roles/imgbuilder/preseed/lib.sls' import preseed_make with context %}

{{ preseed_make(settings) }}

copy-diskpassword:
  file.managed:
    - name: {{ settings.target }}/disk.passwd
    - contents: "{{ settings.diskpassword }}"
    - user: {{ base_settings.user }}
    - group: {{ base_settings.user }}
    - mode: 600

{% from 'roles/imgbuilder/preseed/iso.sls' import mk_install_iso with context %}

{{ mk_install_iso(settings) }}

