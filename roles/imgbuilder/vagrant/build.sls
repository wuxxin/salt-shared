
{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

{% for a in ('empty-box', 'empty-box-22g') %}
{{ a }}:
  file.recurse:
    - source: salt://roles/imgbuilder/vagrant/{{ a }}
    - name: {{ s.image_base }}/templates/{{ a }}
    - user: {{ s.user }}
    - group: libvirtd
    - file_mode: 664
    - dir_mode: 775
    - include_empty: True
  cmd.run:
    - name: cd {{ s.images_base }}/templates/{{ a }}; ./vagrant-box-add.sh
    - user: {{ s.user }}
    - group: {{ s.user }}
{{ endfor }}
