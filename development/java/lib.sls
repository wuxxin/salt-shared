
{% macro user_install_webstart(user, name, url, unless_exists="") %}

webstart-install-{{ name }}:
  cmd.run:
    - name: javaws -Xnosplash -import -silent -headless {{ url }}
    - runas: {{ user }}
  {% if unless_exists != "" %}    
    - unless: test -e {{ unless_exists }}
  {% endif %}

{% endmacro %}
