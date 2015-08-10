{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}


{% macro prepare_template(template, name, targetdir, varsfile={}) %}

"packer_templates_{{ targetdir }}":
  file.recurse:
    - source: salt://roles/imgbuilder/packer/templates
    - name: {{ targetdir }}
    - user: {{ s.user }}
    - group: libvirtd
    - file_mode: 664
    - dir_mode: 775
    - include_empty: True

"box_add_script_{{ targetdir }}":
  file.managed:
    - name: {{ targetdir }}/vagrant-box-add.sh
    - user: {{ s.user }}
    - group: libvirtd
    - mode: 775
    - require:
      - file: "packer_templates_{{ targetdir }}"

"user_template_{{ targetdir }}":
  file.managed:
    - source: {{ template }}
    - name: {{ targetdir }}/{{ name }}.json
    - user: {{ s.user }}
    - group: libvirtd
    - require:
      - file: "box_add_script_{{ targetdir }}"

"user_varsfile_{{ targetdir }}":
  file.managed:
    - name: {{ targetdir }}/{{ name }}_vars.json
    - contents: |
{{ varsfile|json(False)|indent(8, True) }}
    - user: {{ s.user }}
    - group: libvirtd
    - require:
      - file: "user_template_{{ targetdir }}"

{% endmacro %}


{% macro prepare_preseed(name, targetdir, custom_settings= {}) %}

{% from "roles/imgbuilder/preseed/defaults.jinja" import defaults as ps_s with context %}

# our updates
{% do ps_s.update({
  'target': targetdir+ "/http",
  'username': 'vagrant',
  'password': 'vagrant',
  'hostname': name,
  'default_preseed': 'preseed-simple-http.cfg',
}) %}

# updates from caller
{% do ps_s.update(custom_settings) %}

{% from 'roles/imgbuilder/preseed/lib.sls' import add_preseed_files with context %}
{{ add_preseed_files(ps_s, ps_s.target) }}

{% endmacro %}


{% macro build_machine(name, targetdir, varscmd={}, cmdextra="-only=qemu ") %}

{% set vars=[] %}
{% for n, d in varscmd.iteritems() %}
{% do vars.append([' -var "', n, '=', d, '"']|join('')) %}
{% endfor %}

build_{{ targetdir }}":
  cmd.run:
    - name: if test -d output-qemu; then rm -r output-qemu; fi; PACKER_LOG=1 packer build -var-file {{ targetdir }}/{{ name }}_vars.json {{ vars|join("") }} {{ cmdextra }} {{ name }}.json
    - cwd: {{ targetdir }}
    - user: {{ s.user }}
    - group: {{ s.user }}

{% endmacro %}
