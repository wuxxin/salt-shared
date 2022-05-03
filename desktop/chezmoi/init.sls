{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% set workdir= user_home+ '/.local/share/chezmoi' %}
{% set configfile= user_home+ '/.config/chezmoi/chezmoi.toml' %}
{# .chezmoiroot #}

chezmoi:
  pkg:
    - installed
