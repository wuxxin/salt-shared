{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

{% for name in ['trusty-simple'] %}
build_{{ name }}:
  cmd.run:
    - name: cd {{ s.image_base }}/templates/packer; rm -r output-qemu; packer build --only=qemu {{ name }}.json && ./vagrant-box-add.sh
    - user: {{ s.user }}
    - group: {{ s.user }}
{% endfor %}
