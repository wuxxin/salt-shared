{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

packer_refresh:
  cmd.run:
    - name: "cd {{ s.image_base}}/templates/packer/ && for a in `find . | grep -v '/packer_cache'`; do rm $a; done"

packer_templates:
  file.recurse:
    - source: salt://roles/imgbuilder/packer/templates
    - name: {{ s.image_base}}/templates/packer/
    - user: {{ s.user }}
    - group: libvirtd
    - file_mode: 664
    - dir_mode: 775
    - include_empty: True
    - require:
      - cmd: packer_refresh
    #- template: jinja

box_add_script:
  file.managed:
    - name: {{ s.image_base}}/templates/packer/vagrant-box-add.sh
    - user: {{ s.user }}
    - group: libvirtd
    - mode: 775
    - require:
      - file: packer_templates

{% from "roles/imgbuilder/preseed/defaults.jinja" import defaults as ps_s with context %}
{% do ps_s.update({
  'target': s.image_base+ '/templates/packer/http',
  'username': 'vagrant',
  'password': 'vagrant',
  'hostname': 'trusty',
  'default_preseed': 'preseed-custom-http.cfg',
}) %}

{#
  'custom_files':(
    ('/.ssh/authorized_keys', 'salt://roles/imgbuilder/preseed/files/vagrant.pub'),
  ),
#}

{% from 'roles/imgbuilder/preseed/lib.sls' import add_preseed_files with context %}
{{ add_preseed_files(ps_s, ps_s.target) }}

{% for name in ['trusty'] %}
{#
build_{{ name }}:
  cmd.run:
    - name: cd {{ s.image_base }}/templates/packer; rm -r output-qemu; packer build --only=qemu {{ name }}.json && ./vagrant-box-add.sh
    - user: {{ s.user }}
    - group: {{ s.user }}
#}
{% endfor %}
