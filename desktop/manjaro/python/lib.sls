{% macro jupyter_user_kernel(user, name, pkgs=[], system_packages=True, rebuild=False) %}
  {% set BASE_DIR= salt['user.info'](user)['home'] ~ '/.local/lib/ipykernel' %}
  {% set VIRTUAL_ENV= BASE_DIR ~ '/' ~ name %}

create_jupyter_python_env_{{ name }}:
  file.directory:
    - name: {{ BASE_DIR }}
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: true
  cmd.run:
    - name: python -m venv {{ '--system-site-packages' if system_packages }} {{ VIRTUAL_ENV }}
    - unless: test -f {{ VIRTUAL_ENV }}/bin/activate
    - user: {{ user }}
    - group: {{ user }}
  {%- if 'require' in kwargs %}
    - require:
    {%- set data = kwargs['require'] %}
    {%- if data is sequence and data is not string %}
      {%- for value in data %}
      - {{ value }}
      {%- endfor %}
    {%- else %}
      - {{ data }}
    {%- endif %}
  {%- endif %}

install_ipykernel_and_packages_{{ name }}:
  pip.installed:
    - user: {{ user }}
    - group: {{ user }}
    - pkgs: {{ ['ipykernel'] + pkgs }}
    - bin_env: {{ VIRTUAL_ENV }}
    - use_vt: true
    - require:
      - cmd: create_jupyter_python_env_{{ name }}

register_ipykernel_{{ name }}:
  cmd.run:
    - name: python -m ipykernel install --user --name={{ name }}
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - pip: install_ipykernel_and_packages_{{ name }}

installed_jupyter_kernel_{{ name }}:
  test.nop:
    - require:
      - cmd: register_ipykernel_{{ name}}

{% endmacro %}


{% macro jupyter_user_service(user, notebook_dir) %}

  {% from 'desktop/user/lib.sls' import user_desktop %}
  {% set basename= salt['file.basename'](notebook_dir) %}
  {% set home= salt['user.info'](user)['home'] %}
  {% set WMID= 'jupterlab_' ~ salt['cmd.run_stdout'](
    'python -c "import binascii; print(\'{:x}\'.format(binascii.crc_hqx(b\'' ~
    notebook_dir ~ '\', 0)))"' ) %}
  {% set ice_profile= home ~ '.local/share/ice/profiles/' ~ WMID %}
  {% set WMClass= 'WebApp-' ~ WMID %}
  {% set token= '' %}
  {% set port= '8888' %}

# create a systemd user service for starting jupyter lab in background without gui
jupyter_user_service_{{ WMID }}:
  file.managed:
    - name: {{ home }}/.config/systemd/user/{{ WMID }}.service
    - contents: |
        [Unit]
        Description=Jupyter notebook server ({{ notebook_dir }})

        [Service]
        Type=simple
        WorkingDirectory={{ notebook_dir }}
        Restart=on-failure
        ExecStart=jupyter lab \
          --notebook-dir={{ notebook_dir }} \
          --ip=localhost \
          --port={{ port }} \
          --pylab=True \
          --NotebookApp.token='{{ token }}' \
          --no-browser

        # --autoreload \
        # --collaborative \

        [Install]
        WantedBy=default.target

  {%- if 'require' in kwargs %}
    - require:
    {%- set data = kwargs['require'] %}
    {%- if data is sequence and data is not string %}
      {%- for value in data %}
      - {{ value }}
      {%- endfor %}
    {%- else %}
      - {{ data }}
    {%- endif %}
  {%- endif %}


{% load_yaml as desktop_config %}
Type: Application
Name: Jupyterlab-{{ basename }}
Comment: Jupyter Lab Web-App ({{ notebook_dir }})
Icon: jupyter
Categories: Development;Science;GTK;Network;
Exec: chromium --app=http://localhost:{{ port }}/lab?token={{ token }} --class={{ WMClass }} --user-data-dir={{ ice_profile }}
Path: {{ notebook_dir }}
StartupWMClass: {{ WMClass }}
StartupNotify: true
X-MultipleArgs: false
X-WebApp-Browser: Chromium
X-WebApp-URL: http://localhost:{{ port }}/lab?token={{ token }}
X-WebApp-Isolated: true
{% endload %}

# create a jupyterlab desktop entry to start the gui-browser as "app"
{{ user_desktop(user, desktop_config, require='file: jupyter_user_service_'~ WMID) }}


installed_jupyter_user_service_{{ WMID }}:
  test.nop:
    - require:
      - file: jupyter_user_service_{{ WMID }}
      - file: {{ desktop_config.Name }}.desktop

{% endmacro %}
