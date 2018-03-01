include:
  - .base

{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

{% macro user_install_oxt(user, identifier, url) %}

install_oxt_{{ user }}_{{ identifier }}:
  cmd.run:
    - name: unopkg add -s {{ url }}
    - user: {{ user }}
    - unless: unopkg list | grep -q "{{ identifier }}"

{% endmacro %}

{{ user_install_oxt(user, 
  "org.openoffice.languagetool.oxt", 
  "https://languagetool.org/download/LanguageTool-4.0.oxt"
  ) }}

{{ user_install_oxt(user, 
  "de.openthesaurus", 
  "https://www.openthesaurus.de/export/Deutscher-Thesaurus.oxt"
  ) }}
  
