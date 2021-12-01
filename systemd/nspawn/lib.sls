
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
  file.managed:
    - name: {{ settings.store.mkosi_config }}/{{ name }}/mkosi.default
    - source: salt://systemd/nspawn/mkosi-template.jinja
    - template: jinja
    - defaults:
        dataset: {{ settings.image[template]['mkosi'] }}
    - require:
      - file: mkosi_config_dir_{{ name }}

mkosi_config_nspawn_{{ name }}:
  file.managed:
    - name: {{ settings.store.mkosi_config }}/{{ name }}/mkosi.nspawn
    - source: salt://systemd/nspawn/nspawn-template.jinja
    - template: jinja
    - defaults:
        dataset: {{ settings.image[template]['nspawn'] }}

mkosi_config_postinst_{{ name }}:
  file.managed:
    - source: salt://systemd/nspawn/mkosi.postinst
    - name: {{ settings.store.mkosi_config }}/{{ name }}/mkosi.postinst
    - mode: "755"

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
  {%- from "systemd/nspawn/defaults.jinja" import settings with context %}
  {%- set this= salt['grains.filter_by']({'default': settings.image[definition.image]['machine']},
    grain='default', default= 'default', merge=definition) %}
  
nspawn_image_{{ this.name }}:
  cmd.run:
    - name: |
        machinectl import-fs \
            {{ settings.store.mkosi_target }}/{{ this.image }} {{ this.name }}
    - unless: test -e {{ settings.store.nspawn_target }}/{{ this.name }}

nspawn_config_{{ this.name }}:
  file.managed:
    - name: {{ settings.store.nspawn_config }}/{{ this.name }}.nspawn
    - source: salt://systemd/nspawn/nspawn-template.jinja
    - template: jinja
    - mode: "600"
    - defaults:
        dataset: {{ this.nspawn }}
        environment: {{ this.environment }}
    - require:
      - cmd: nspawn_image_{{ this.name }}

  {% if this.enabled %}
nspawn_start_{{ this.name }}:
  cmd.run:
    - name: machinectl start {{ this.name }}
    - require:
      - cmd: nspawn_image_{{ this.name }}
      - file: nspawn_config_{{ this.name }}

nspawn_started_{{ this.name }}:
  cmd.run:
    - name: |
        while ! machinectl list -a --no-legend | grep -q ^{{ this.name }}; do
            echo -n "."; sleep 1
        done
        while ! machinectl show {{ this.name }} | grep -q State=running; do
            echo -n "+"; sleep 1
        done
        sleep 1
        echo " machine {{ this.name }} is running"
    - require:
      - cmd: nspawn_start_{{ this.name }}

    {% if this.postinst.source %}

nspawn_postinst_copy_{{ this.name }}:
  file.managed:
    - name: {{ settings.store.nspawn_run }}/{{ this.name }}.postinst
    - source: {{ this.postinst.source }}
    - onlyif: test ! -e {{ settings.store.nspawn_config }}/{{ this.name }}.postinst.done
  cmd.run:
    - name: |
        machinectl copy-to {{ this.name }} \
          {{ settings.store.nspawn_run }}/{{ this.name }}.postinst \
          /tmp/machine.postinst
    - onlyif: test ! -e {{ settings.store.nspawn_config }}/{{ this.name }}.postinst.done
    - require:
      - file: nspawn_postinst_copy_{{ this.name }}

nspawn_authorized_keys_copy_{{ this.name }}:
  file.managed:
    - name: {{ settings.store.nspawn_run }}/{{ this.name }}.authorized_keys
    - onlyif: test ! -e {{ settings.store.nspawn_config }}/{{ this.name }}.postinst.done
    - contents: |
{{ this.postinstall.authorized_keys|indent(8, true) }}
  cmd.run:
    - name: |
        machinectl copy-to {{ this.name }} \
          {{ settings.store.nspawn_run }}/{{ this.name }}.authorized_keys \
          /tmp/authorized_keys
    - onlyif: test ! -e {{ settings.store.nspawn_config }}/{{ this.name }}.postinst.done
    - require:
      - file: nspawn_authorized_keys_copy_{{ this.name }}

nspawn_postinst_exec_{{ this.name }}:
  cmd.run:
    - name: |
        machinectl shell {{ this.name }} \
          /bin/sh -c '/bin/chmod +x /tmp/machine.postinst; /tmp/machine.postinst {{ this.postinst.args|join(' ') }}'
    - onlyif: test ! -e {{ settings.store.nspawn_config }}/{{ this.name }}.postinst.done
    - require:
      - cmd: nspawn_postinst_copy_{{ this.name }}
      - cmd: nspawn_authorized_keys_copy_{{ this.name }}

nspawn_create_postinst_done_{{ this.name }}:
  cmd.run:
    - name: touch {{ settings.store.nspawn_config }}/{{ this.name }}.postinst.done
    - onlyif: test ! -e {{ settings.store.nspawn_config }}/{{ this.name }}.postinst.done
    - require:
      - cmd: nspawn_postinst_exec_{{ this.name }}
      {% endif %}

  {% else %}
nspawn_stop_{{ this.name }}:
  cmd.run:
    - name: machinectl stop {{ this.name }} || true
    - require:
      - cmd: nspawn_image_{{ this.name }}
      - file: nspawn_config_{{ this.name }}
  {% endif %}

{% endmacro %}
