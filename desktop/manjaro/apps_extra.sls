{% from 'manjaro/lib.sls' import pamac_install, pamac_repo_key with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'python/lib.sls' import pipx_install, pipx_inject %}

{% load_yaml as pkgs %}
      - vcvrack
      - vcvrack-goodsheperd
      - vcvrack-freesurface
      - vcvrack-cvly
      - vcvrack-computerscare
      - vcvrack-collection-one
      - vcvrack-alikins
      - vcvrack-ahornberg
      - vcvrack-aaronstatic
{% endload %}
{{ pamac_install("audio-synthesizer-aur", pkgs) }}

