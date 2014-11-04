include:
  - .user
  - .local-ruby
  - .packer
  - .vagrant
  - .preseed


{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

{{ s.image_base }}/templates/imgbuilder:
  file.directory:
    - user: {{ s.user }}
    - group: libvirtd
    - mode: 775
    - makedirs: True
    - require:
      - user: {{ s.user }}
