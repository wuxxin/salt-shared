{% macro create_python_kernel(user, name, pkgs=[], system_packages=True) %}
  {% set HOME= salt['user.info'](user)['home'] %}
  {% set BASE_DIR= HOME ~ '/.local/share/virtualenvs' %}
  {% set VIRTUAL_ENV= BASE_DIR ~ '/' ~ name %}

python_kernel_{{ name }}:
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
      - file: python_kernel_{{ name }}
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
    - pkgs: {{ ['ipykernel', 'ipywidgets'] + pkgs }}
    - user: {{ user }}
    - cwd: {{ HOME }}
    - bin_env: {{ VIRTUAL_ENV }}
    - require:
      - cmd: python_kernel_{{ name }}

{% endmacro %}


{% macro register_python_kernel(user, name) %}
  {% set HOME= salt['user.info'](user)['home'] %}
  {% set BASE_DIR= HOME ~ '/.local/share/virtualenvs' %}
  {% set VIRTUAL_ENV= BASE_DIR ~ '/' ~ name %}

register_python_kernel_{{ name }}:
  cmd.run:
    - name: {{ VIRTUAL_ENV }}/bin/python -m ipykernel install --user --name={{ name }}
    - runas: {{ user }}
    - cwd: {{ HOME }}
    - env:
        USER: {{ user }}
        HOME: {{ HOME }}
        VIRTUAL_ENV: {{ VIRTUAL_ENV }}
  {%- if 'require' in kwargs %}
    {%- set data = kwargs['require'] %}
    - require:
    {%- if data is sequence and data is not string %}
      {%- for value in data %}
      - {{ value }}
      {%- endfor %}
    {%- else %}
      - {{ data }}
    {%- endif %}
  {%- endif %}
{% endmacro %}


{% macro jupyter_core(user, pkgs, apps) %}
  {% from 'python/lib.sls' import pipx_install, pipx_inject %}

# create a pipx environment for jupyter[lab] service
{{ pipx_install('jupyter-core', user=user, pipx_opts='--system-site-packages --pip-args="-I"') }}
# inject additional packages if defined into environment
{{ pipx_inject('jupyter-core', pkgs, user, pipx_opts='--system-site-packages') }}
# inject additional apps if defined into environment
{{ pipx_inject('jupyter-core', apps, user, pipx_opts='--include-apps --system-site-packages') }}

{% endmacro %}


{% macro jupyter_service(user, notebook_dir, port, token, chromium_args, chromium_extensions) %}
  {% from 'desktop/user/lib.sls' import user_desktop %}
  {% set home= salt['user.info'](user)['home'] %}
  {% set JUPYTERLAB_ID= 'jupyter-core' %}
  {% set WMClass= 'WebApp-' ~ JUPYTERLAB_ID %}
  {% set ice_profile= home ~ '/.local/share/ice/profiles/' ~ JUPYTERLAB_ID %}
  {% set chromium_args= ' '.join(chromium_args) %}

# create a systemd user service for starting jupyter lab in background without gui
jupyter_service_{{ JUPYTERLAB_ID }}:
  file.managed:
    - name: {{ home }}/.config/systemd/user/{{ JUPYTERLAB_ID }}.service
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: true
    - contents: |
        [Unit]
        Description=Jupyter notebook server

        [Service]
        Type=simple
        WorkingDirectory={{ notebook_dir }}
        Restart=always
        # Environment=HIP_LAUNCH_BLOCKING=1
        # Environment=AMD_LOG_LEVEL=3
        ExecStart={{ home }}/.local/bin/jupyter lab \
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
    - runas: {{ user }}
    - onchanges:
      - file: jupyter_service_{{ JUPYTERLAB_ID }}

{% load_yaml as desktop_config %}
Type: Application
Name: Jupyter Lab
Comment: Jupyter (Web-App ({{ notebook_dir }})
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
{{ user_desktop(user, WMClass|lower(), desktop_config, require='file: jupyter_service_'~ JUPYTERLAB_ID) }}

installed_jupyter_service_{{ JUPYTERLAB_ID }}:
  test.nop:
    - require:
      - file: jupyter_service_{{ JUPYTERLAB_ID }}
      - file: {{ WMClass|lower() }}.desktop

{% endmacro %}
