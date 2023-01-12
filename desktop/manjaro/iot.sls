{% from 'manjaro/lib.sls' import pamac_install, pamac_repo_key with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - desktop.manjaro.emulator
  - desktop.manjaro.python

{% load_yaml as pkgs %}
      # rshell - remote shell for working with MicroPython boards
      - rshell-micropython-git
      # micropy-cli - project management/generation tool for writing Micropython code in modern IDEs
      - python-micropy-cli
{% endload %}
{{ pamac_install("micropython-tools-aur", pkgs) }}