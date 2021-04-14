{%- if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 '+
  '"https://riot.im/packages/debian/dists/'+ grains['oscodename']+
  '/InRelease" | grep -qE "^HTTP/[12]\.?1? 200"', python_shell=true) == 0 %}

riot:
  pkgrepo.managed:
    - name: deb https://riot.im/packages/debian/ {{ grains['oscodename'] }} main
    - key_url: https://riot.im/packages/debian/repo-key.asc
    - file: /etc/apt/sources.list.d/riot.im_ppa.list
    - require_in:
      - pkg: riot
  pkg.installed:
    - name: riot-web

{% endif %}
