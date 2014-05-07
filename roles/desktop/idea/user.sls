{% from 'roles/desktop/user/lib.sls' import user, user_home with context %}

idea-desktop-icon:
  file.managed:
    - source: salt://roles/desktop/idea/idea.desktop
    - name: {{ user_home }}/.local/share/applications/idea.desktop
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: true
