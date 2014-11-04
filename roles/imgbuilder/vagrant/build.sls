
{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

empty-box:
  file.recurse:
    - source: salt://roles/imgbuilder/vagrant/empty-box
    - name: {{ s.image_base }}/templates/empty-box
    - user: {{ s.user }}
    - group: libvirtd
    - file_mode: 664
    - dir_mode: 775
    - include_empty: True
  cmd.run:
    - name: cd {{ s.images_base }}/templates/empty-box; ./vagrant-box-add.sh
    - user: {{ s.user }}
    - group: {{ s.user }}
