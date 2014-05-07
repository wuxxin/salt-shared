
{% for name in ['trusty'] %}
 # 'precise', 'saucy', 'trusty'

build_{{ name }}:
  cmd.run:
    - name: cd /mnt/images/templates/packer; packer build --only=qemu {{ name }}.json && ./vagrant-box-add.sh
    - user: imgbuilder
    - group: imgbuilder

{% endfor %}

