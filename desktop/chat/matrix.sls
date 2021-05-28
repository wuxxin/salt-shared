{% set oscodename = grains['oscodename'] %}
{% if oscodename == 'focal' %}{% set oscodename = 'default' %}{% endif %}

{%- if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 '+
  '"https://riot.im/packages/debian/dists/'+ oscodename+
  '/InRelease" | grep -qE "^HTTP/[12]\.?1? 200"', python_shell=true) == 0 %}

element:
  pkgrepo.managed:
    - name: deb https://packages.riot.im/debian/ {{ oscodename }} main
    - key_url: https://packages.riot.im/debian/riot-im-archive-keyring.asc
    - file: /etc/apt/sources.list.d/riot.im_ppa.list
    - require_in:
      - pkg: element
  pkg.installed:
    - name: element-desktop

{% endif %}
