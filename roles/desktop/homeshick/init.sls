{% from 'roles/desktop/user/lib.sls' import user, user_info, user_home with context %}
{% set workdir= user_home+ '/.homesick/repos/homeshick' %}

homeshick:
  file.directory:
    - name: {{ workdir }}
    - makedirs: true
    - user: {{ user }}
  git.latest:
    - name: https://github.com/andsens/homeshick.git
    - target: {{ workdir }}
    - user: {{ user }}
    - require:
      - file: homeshick

homeshick_bashrc:
  file.append:
    - name: {{ user_home }}/.bashrc
    - text:
      - source "$HOME/.homesick/repos/homeshick/homeshick.sh"
      - homeshick --quiet refresh
    - require:
      - git: homeshick
