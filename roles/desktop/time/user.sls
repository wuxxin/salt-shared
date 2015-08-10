{% from 'roles/desktop/user/lib.sls' import user, user_home with context %}

{% if grains['os'] == 'Mint' %}

hamster_cinnamon:
  git.latest:
    - name: https://github.com/projecthamster/cinnamon-applet.git
    - target:  {{ user_home }}/.local/share/cinnamon/applets/hamster@projecthamster.wordpress.com
    - user: {{ user }}
    
{% endif %}
