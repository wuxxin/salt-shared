{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}


{% macro prepare(name, template, targetdir, custom_files={'custom_files': {}}, varsfile={}, varscmd={}, cmdextra="-only=qemu ") %}

packer_templates_{{ name }}:
  file.recurse:
    - source: salt://roles/imgbuilder/packer/templates
    - name: {{ targetdir }}
    - user: {{ s.user }}
    - group: libvirtd
    - file_mode: 664
    - dir_mode: 775
    - include_empty: True

box_add_script_{{ name }}:
  file.managed:
    - name: {{ targetdir }}/vagrant-box-add.sh
    - user: {{ s.user }}
    - group: libvirtd
    - mode: 775
    - require:
      - file: packer_templates_{{ name }}

user_template_{{ name }}:
  file.managed:
    - source: {{ template }}
    - name: {{ targetdir }}/{{ name }}.json
    - user: {{ s.user }}
    - group: libvirtd
    - require:
      - file: box_add_script_{{ name }}

user_varsfile_{{ name }}:
  file.managed:
    - name: {{ targetdir }}/{{ name }}_vars.json
    - contents: |
{{ varsfile|yaml(False)|indent(8, True) }}
    - user: {{ s.user }}
    - group: libvirtd
    - require:
      - file: user_template_{{ name }}

{% from "roles/imgbuilder/preseed/defaults.jinja" import defaults as ps_s with context %}
{% do ps_s.update({
  'target': targetdir+ '/http',
  'username': 'vagrant',
  'password': 'vagrant',
  'hostname': name,
  'default_preseed': 'preseed-simple-http.cfg',
}) %}

{% do ps_s.update(custom_files) %}

{# example:
  load_yaml as custom_files
  custom_files:
    '/.ssh/authorized_keys': 'salt://roles/imgbuilder/preseed/files/vagrant.pub'
#}

{% from 'roles/imgbuilder/preseed/lib.sls' import add_preseed_files with context %}
{{ add_preseed_files(ps_s, ps_s.target) }}

{% endmacro %}


{% macro build(name, template, targetdir, custom_files={'custom_files': {}}, varsfile={}, varscmd={}, cmdextra="-only=qemu ") %}
{% set vars=[] %}
{% for n, d in varscmd.iteritems() %}
{% do vars.append([' -var "', n, '=', d, '"']|join('')) %}
{% endfor %}

build_{{ name }}:
  cmd.run:
    - name: if test -d output-qemu; then rm -r output-qemu; fi; packer build -var-file {{ targetdir }}/{{ name }}_vars.json {{ vars|join("") }} {{ cmdextra }} {{ name }}.json
    - cwd: {{ targetdir }}
    - user: {{ s.user }}
    - group: {{ s.user }}

{% endmacro %}
