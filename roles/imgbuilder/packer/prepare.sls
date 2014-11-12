
{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

{% for name in ['trusty'] %}
 # 'precise', 'saucy', 'trusty'

build_{{ name }}:
  cmd.run:
    - name: cd {{ s.image_base }}/templates/packer; packer build --only=qemu {{ name }}.json && ./vagrant-box-add.sh
    - user: imgbuilder
    - group: imgbuilder

{% endfor %}

