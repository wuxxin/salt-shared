
{% macro volume(name) %}
  {%- from "systemd/nspawn/defaults.jinja" import settings with context %}

nspawn_volume_{{ name }}:
  file.directory:
    - name: {{ settings.store.nspawn_volume }}/{{ name }}
    - mode: 0700
    - makedirs: true

{% endmacro %}


{% macro image(name, template) %}
  {%- from "systemd/nspawn/defaults.jinja" import settings with context %}

mkosi_config_dir_{{ name }}:
  file.directory:
    - name: {{ settings.store.mkosi_config }}/{{ name }}

mkosi_config_default_{{ name }}:
  file.serialize:
    - name: {{ settings.store.mkosi_config }}/{{ name }}/mkosi.default
    - dataset: {{ settings.image.mkosi[template] }}
    - formatter: toml
    - require:
      - file: mkosi_config_dir_{{ name }}

mkosi_config_nspawn_{{ name }}:
  file.serialize:
    - name: {{ settings.store.mkosi_config }}/{{ name }}/mkosi.nspawn
    - dataset: {{ settings.image.nspawn[template] }}
    - formatter: toml

mkosi_config_postinst_{{ name }}:
  file.managed:
    - source: salt://systemd/nspawn/mkosi.postinst
    - name: {{ settings.store.mkosi_config }}/{{ name }}/mkosi.postinst

mkosi_image_{{ name }}:
  cmd.run:
    - name: |
        mkosi --directory={{ settings.store.mkosi_config }}/{{ name }} \
              --output={{ settings.store.mkosi_target }}/{{ name }} \
              --cache={{ settings.store.mkosi_cache }}
    - unless: test -e {{ settings.store.mkosi_target }}/{{ name }}
    - require:
      - file: mkosi_config_default_{{ name }}
      - file: mkosi_config_nspawn_{{ name }}
      - file: mkosi_config_postinst_{{ name }}

{% endmacro %}


{% macro machine(definition) %}
  {%- from "systemd/nspawn/defaults.jinja" import settings, machine_defaults with context %}
  {%- set this= salt['grains.filter_by']({'default': machine_defaults},
    grain='default', default= 'default', merge=definition) %}

nspawn_env_{{ this.name }}:
  file.managed:
    - name: {{ settings.store.nspawn_env }}/{{ this.name }}.env
    - mode: 0600
    - contents: |
  {%- for key,value in this.environment.items() %}
        {{ key }}={{ value }}
  {%- endfor %}

nspawn_image_{{ this.name }}:
  cmd.run:
    - name: |
        machinectl import-fs \
            {{ settings.store.mkosi_target }}/{{ this.name }} \
            {{ this.name }}
    - unless: test -e {{ settings.store.nspawn_target }}/{{ name }}

nspawn_config_{{ this.name }}:
  file.serialize:
    - name: {{ settings.store.nspawn_config }}/{{ this.name }}.nspawn
    - dataset: {{ this.nspawn }}
    - formatter: toml
    - require:
      - cmd: nspawn_image_{{ this.name }}

nspawn_start_{{ this.name }}:
  cmd.run:
    - name: machinectl start {{ this.name }}
    - require:
      - file: nspawn_env_{{ this.name }}
      - cmd: nspawn_image_{{ this.name }}
      - file: nspawn_config_{{ this.name }}:

{% endmacro %}
