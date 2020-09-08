
rspamd:
  pkgrepo.managed:
    - name: deb [arch=amd64] http://rspamd.com/apt-stable/ {{ grains['oscodename'] }} main
    - key_url: https://rspamd.com/apt-stable/gpg.key
    - file: /etc/apt/sources.list.d/rpspamd.list
    - require_in:
      - pkg: rspamd
  pkg.installed:
    - name: rspamd
