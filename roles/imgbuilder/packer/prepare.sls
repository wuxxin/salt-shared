
{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

{% for name in ['trusty'] %}
 # 'precise', 'saucy', 'trusty'

build_{{ name }}:
  cmd.run:
    - name: cd {{ s.image_base }}/templates/packer; packer build --only=qemu {{ name }}.json && ./vagrant-box-add.sh
    - user: imgbuilder
    - group: imgbuilder

{% endfor %}

{% from "roles/imgbuilder/preseed/defaults.jinja" import defaults as ps_s with context %}
{% do ps_s.update({
  'target': s.image_base+ '/templates/packer/http',
  'username': 'vagrant',
  'password': 'vagrant',
  'hostname': 'trusty',
  'custom_files':(
    ('/.ssh/authorized_keys', 'salt://roles/imgbuilder/preseed/files/vagrant.pub'),
  ),
  'default_preseed': 'preseed-custom.cfg',
}) %}

{% from 'roles/imgbuilder/preseed/lib.sls' import add_preseed_files with context %}
{{ add_preseed_files(ps_s) }}

