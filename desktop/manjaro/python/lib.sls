{% macro jupyter_user_kernel(user, name, pkgs=[], system_packages=True) %}
  {% set HOME= salt['user.info'](user)['home'] %}
  {% set BASE_DIR= HOME ~ '/.local/share/jupyter/kernels' %}
  {% set VIRTUAL_ENV= BASE_DIR ~ '/' ~ name %}

jupyter_user_kernel_{{ name }}:
  file.directory:
    - name: {{ BASE_DIR }}
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: true
  cmd.run:
    - name: python -m venv {{ '--system-site-packages' if system_packages }} {{ VIRTUAL_ENV }}
    - unless: test -f {{ VIRTUAL_ENV }}/bin/activate
    - runas: {{ user }}
    - cwd: {{ HOME }}
    - require:
      - file: jupyter_user_kernel_{{ name }}
  {%- if 'require' in kwargs %}
    {%- set data = kwargs['require'] %}
    {%- if data is sequence and data is not string %}
      {%- for value in data %}
      - {{ value }}
      {%- endfor %}
    {%- else %}
      - {{ data }}
    {%- endif %}
  {%- endif %}
  pip.installed:
    - pkgs: {{ ['ipykernel'] + pkgs }}
    - user: {{ user }}
    - cwd: {{ HOME }}
    - bin_env: {{ VIRTUAL_ENV }}
    - require:
      - cmd: jupyter_user_kernel_{{ name }}

register_jupyter_user_kernel_{{ name }}:
  cmd.run:
    - name: {{ VIRTUAL_ENV }}/bin/python -m ipykernel install --user --name={{ name }}
    - runas: {{ user }}
    - cwd: {{ HOME }}
    - env:
        USER: {{ user }}
        HOME: {{ HOME }}
        VIRTUAL_ENV: {{ VIRTUAL_ENV }}
    - require:
      - pip: jupyter_user_kernel_{{ name }}

{% endmacro %}


{% macro jupyter_user_service(user, notebook_dir, port, token, chromium_flags) %}
  {% from 'desktop/user/lib.sls' import user_desktop %}
  {% set basename= salt['file.basename'](notebook_dir) %}
  {% set home= salt['user.info'](user)['home'] %}
  {% set WMID= 'jupyterlab_' ~ salt['cmd.run_stdout'](
    'python -c "import binascii; print(\'{:x}\'.format(binascii.crc_hqx(b\'' ~
    notebook_dir ~ '\', 0)))"' ) %}
  {% set ice_profile= home ~ '/.local/share/ice/profiles/' ~ WMID %}
  {% set WMClass= 'WebApp-' ~ WMID %}
  {% set chromium_args= ' '.join(chromium_flags) %}

# create a systemd user service for starting jupyter lab in background without gui
jupyter_user_service_{{ WMID }}:
  file.managed:
    - name: {{ home }}/.config/systemd/user/{{ WMID }}.service
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: true
    - contents: |
        [Unit]
        Description=Jupyter notebook server ({{ notebook_dir }})

        [Service]
        Type=simple
        WorkingDirectory={{ notebook_dir }}
        Restart=always
        # Environment=HIP_LAUNCH_BLOCKING=1
        # Environment=AMD_LOG_LEVEL=3
        ExecStart=jupyter lab \
          --notebook-dir={{ notebook_dir }} \
          --ip=localhost \
          --port={{ port }} \
          --ServerApp.token='{{ token }}' \
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
  cmd.run:
    - name: systemctl --user daemon-reload
    - onchanges:
      - file: jupyter_user_service_{{ WMID }}

{% load_yaml as desktop_config %}
Type: Application
Name: Jupyterlab {{ basename }}
Comment: Jupyter Lab Web-App ({{ notebook_dir }})
Icon: notebook
Categories: Development;Science;Education;Network;
Keywords: python;
Exec: /usr/lib/chromium/chromium --app=http://localhost:{{ port }}/lab?token={{ token }} --class={{ WMClass }} --user-data-dir={{ ice_profile }} {{ chromium_args }}
Path: {{ notebook_dir }}
StartupWMClass: {{ WMClass }}
StartupNotify: true
SingleMainWindow: true
X-MultipleArgs: false
X-WebApp-Browser: Chromium
X-WebApp-URL: http://localhost:{{ port }}/lab?token={{ token }}
X-WebApp-Isolated: true
{% endload %}

# create a jupyterlab desktop entry to start the gui-browser as "app"
{{ user_desktop(user, WMClass|lower(), desktop_config, require='file: jupyter_user_service_'~ WMID) }}

installed_jupyter_user_service_{{ WMID }}:
  test.nop:
    - require:
      - file: jupyter_user_service_{{ WMID }}
      - file: {{ WMClass|lower() }}.desktop

{% endmacro %}
