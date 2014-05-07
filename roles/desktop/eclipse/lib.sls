{% set inst_app= 'org.eclipse.equinox.p2.director' %}
{% set main_url= 'http://download.eclipse.org/releases/kepler' %}

{% macro keytool-cert(user, name, url, hash) %}
/tmp/{{ name }}-eclipse-cert:
  file.managed:
    - source: {{ url }}
    - source_hash: {{ hash }}
  cmd.run:
    - name: keytool -import -noprompt -file /tmp/{{ name }}-eclipse-cert
    - user: {{ user }}
    - group: {{ user }}
    - cwd: {{ user_home }}
    - require:
      - file: /tmp/{{ name }}-eclipse-cert
{% endmacro %}

{% macro eclipse-plugin(user, name, url, hash) %}
{{ name }}-eclipse-plugin:
  cmd.run:
    - name: eclipse -nosplash -application {{ inst_app }} -repository {{ main_url }},{{ url }} -installIU {{ group }}
    - user: {{ user }}
    - group: {{ user }}
    - cwd: {{ user_home }}
{% endmacro %}

