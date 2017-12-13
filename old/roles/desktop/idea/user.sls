{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'desktop/idea/init.sls' import idea_ver with context %}

idea-desktop-icon:
  file.managed:
    - source: salt://desktop/idea/idea.desktop
    - name: {{ user_home }}/.local/share/applications/idea.desktop
    - user: {{ user }}
    - template: jinja
    - context:
        idea_ver: {{ idea_ver }}
    - group: {{ user }}
    - makedirs: true
