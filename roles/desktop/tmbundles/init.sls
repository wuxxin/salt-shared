{% from 'roles/desktop/user/lib.sls' import user, user_home with context %}

bundle-dir:
  file.directory:
    - name: "{{ user_home }}/.tmbundle"
    - makedirs: true
    - group: {{ user }}
    - user: {{ user }}

{% for bundle in [
'https://github.com/textmate/yaml.tmbundle.git',
'https://github.com/mitsuhiko/jinja2-tmbundle.git',
'https://github.com/MarioRicalde/SCSS.tmbundle.git',
'https://github.com/textmate/python-django.tmbundle.git',
'https://github.com/textmate/coffee-script.tmbundle.git',
'https://github.com/textmate/json.tmbundle.git',
'https://github.com/textmate/markdown.tmbundle.git',
'https://github.com/textmate/restructuredtext.tmbundle.git',
'https://github.com/textmate/less.tmbundle.git',
'https://github.com/textmate/ssh-config.tmbundle.git',
'https://github.com/textmate/python-django-templates.tmbundle.git',
'https://github.com/textmate/graphviz.tmbundle.git',
] %}
{% set shortname= salt['extutils.re_replace']('.+/([^/]+)\.git', '\\1', bundle) %}

"{{ shortname }}-tmbundle":
  git.latest:
    - name: {{ bundle }}
    - target: {{ user_home }}/.tmbundle/{{ shortname }}
    - user: {{ user }}
    - unless: test -d {{ user_home }}/.tmbundle/{{ shortname }}
    - require:
      - file: bundle-dir
{% endfor %}
