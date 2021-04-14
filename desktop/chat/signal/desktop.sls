{% if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 '+
  '"https://updates.signal.org/desktop/apt/dists/'+ grains['oscodename']+
  '/InRelease" | grep -qE "^HTTP/[12]\.?1? 200"', python_shell=true) == 0 %}

signal:
  pkgrepo.managed:
    - name: deb [arch=amd64] https://updates.signal.org/desktop/apt {{ grains['oscodename'] }} main
    - key_url: https://updates.signal.org/desktop/apt/keys.asc
    - file: /etc/apt/sources.list.d/signal.org_ppa.list
    - require_in:
      - pkg: signal
  pkg.installed:
    - name: signal-desktop

{% endif %}
