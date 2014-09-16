{% from "roles/imgbuilder/preseed/defaults.jinja" import template as settings with context %}

{% do settings.update({'custom_files':(
    ('/.ssh/authorized_keys', 'salt://roles/imgbuilder/preseed/vagrant.pub'),
    ('/reboot.seconds', 'salt://roles/imgbuilder/preseed/reboot.seconds'),
    ('/watch', 'salt://roles/imgbuilder/preseed/watch')
    )}) %}
{% do settings.update({'default_preseed': 'preseed-custom-console.cfg'}) %}
{% do settings.update(
    {'cmdline': 'DEBCONF_DEBUG=5 ro hostname=testing priority=critical debconf/frontend=noninteractive'}) %}

{% from 'roles/imgbuilder/preseed/lib.sls' import preseed_make with context %}

{{ preseed_make(settings) }}

copy-diskpassword:
  file.managed:
    - name: {{ settings.target }}/disk.passwd
    - contents: "{{ settings.diskpassword }}"
    - user: imgbuilder
    - group: imgbuilder
    - mode: 600
