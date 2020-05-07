include:
  - .base

{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

{% macro user_install_oxt(user, identifier, url) %}
  {%- set localfile = user_home+ '/.local/cache/libreoffice-extensions/'+ identifier %}
install_{{ user }}_{{ identifier }}:
  file.managed:
    - source: {{ url }}
    - name: {{ localfile }}
    - skip_verify: true
    - makedirs: true
  cmd.run:
    - name: unopkg add -s {{ localfile }}
    - runas: {{ user }}
    - cwd: {{ user_home }}
    - onchanges:
      - file: install_{{ user }}_{{ identifier }}
{% endmacro %}

{# -  unless: unopkg list | grep -q "{{ identifier }}"  #}

{{ user_install_oxt(user, "org.openoffice.languagetool.oxt",
  "https://languagetool.org/download/LanguageTool-stable.oxt"
  ) }}

{{ user_install_oxt(user, "de.openthesaurus",
  "https://www.openthesaurus.de/export/Deutscher-Thesaurus.oxt"
  ) }}
