include:
  - ubuntu

{%- if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 '+
  '"https://riot.im/packages/debian/dists/'+ grains['oscodename']+
  '/InRelease" | grep -q "200 OK"', python_shell=true) == 0 %}

riot:
  pkgrepo.managed:
    - name: deb https://riot.im/packages/debian/ {{ grains['oscodename'] }} main
    - key_url: https://riot.im/packages/debian/repo-key.asc
    - file: /etc/apt/sources.list.d/riot.im-debian-main.list
    - require:
      - pkg: ppa_ubuntu_installer
    - require_in:
      - pkg: riot
  pkg.installed:
    - name: riot-web

{% endif %}
