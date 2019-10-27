{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from "ubuntu/init.sls" import apt_add_repository %}

{% if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 '+
  '"http://ppa.launchpad.net/micahflee/ppa/ubuntu/dists/'+ grains['oscodename']+
  '/InRelease" | grep -q "200 OK"', python_shell=true) == 0 %}
{{ apt_add_repository("torbrowser-ppa", "micahflee/ppa",
  require_in = "pkg:torbrowser-launcher") }}
{% endif %} 
  
torbrowser-launcher:
  pkg:
    - installed

{# XXX Tor Keys are old, update them first 
update-tor-keys:
  file.directory:
    - name: {{ user_home }}/.local/share/torbrowser/gnupg_homedir
    - user: {{ user }}
    - group: {{ user }}
    - mode: "0700"
  cmd.run:
    - name: gpg --homedir "{{ user_home }}/.local/share/torbrowser/gnupg_homedir/" --refresh-keys --keyserver pool.sks-keyservers.net
    - runas: {{ user }}
    - cwd: {{ user_home }}
    - require:
      - file: update-tor-keys
#}