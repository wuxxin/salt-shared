{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

{% for a in ('empty-box', 'empty-box-26g') %}
{{ a }}:
  file.managed:
    - source: salt://roles/imgbuilder/vagrant/files/vagrant-box-add.sh
    - name: {{ s.image_base }}/templates/{{ a }}/vagrant-box-add.sh
    - user: {{ s.user }}
    - group: libvirtd
    - mode: 755
    - dir_mode: 775
    - makedirs: True

{{ a }}-Vagrantfile:
  file.managed:
    - name: {{ s.image_base }}/templates/{{ a }}/Vagrantfile
    - contents: |
{{ s.Vagrantfile|indent(8,True) }}

    - require:
      - file: {{ a }}

generate-{{ a }}:
  cmd.run:
    - name: cd {{ s.image_base }}/templates/{{ a }}; chmod +x ./vagrant-box-add.sh; ./vagrant-box-add.sh
    - user: {{ s.user }}
    - group: libvirtd
    - require:
      - file: {{ a }}-Vagrantfile

cleanup-{{ a }}:
  file.absent:
    - name: {{ s.image_base }}/templates/{{ a }}
    - require:
      - cmd: generate-{{ a }}

{% endfor %}
